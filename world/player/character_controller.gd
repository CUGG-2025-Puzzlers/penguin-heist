extends Node3D
@onready var _raycast : RayCast3D = %InteractRay
@onready var _snowball_pos : Marker3D = %SnowballPos
@onready var _item_use_timer : Timer = %ItemUseTimer
@onready var _head : Node3D = %Head
@onready var _player_camera : Camera3D = %PlayerCamera

var current_interactable = null

var can_throw = true

var snowball = preload("res://world/items/snowball/snowball.tscn")

var cursor_locked = true

var held_fish = null
var slapping = false

func _ready():
	_item_use_timer.timeout.connect(_on_ItemUseTimer_timeout)

func _physics_process(delta):
	check_hover_collision()
	
	snowball_throw()

func check_hover_collision():
	var item = null

	if _raycast.is_colliding():
		var collider = _raycast.get_collider()

		if collider:
			item = collider.get_parent()

			if not item.has_method("interact"):
				item = null

	if item != current_interactable:
		hide_current_prompt()

		if item:
			current_interactable = item
			current_interactable.show_prompt()

func hide_current_prompt():
	if current_interactable:
		current_interactable.hide_prompt()
		current_interactable = null


func snowball_throw():
	if held_fish:
		if Input.is_action_just_pressed("input_throw"):
			slap()
		return

	if Input.is_action_just_pressed("input_throw") && can_throw:
		var snowball_ins = snowball.instantiate()
		snowball_ins.position = _snowball_pos.global_position
		get_tree().current_scene.add_child(snowball_ins)
		
		can_throw = false
		_item_use_timer.start()
		
		var force = -0.5
		var upDirection = 0.05
		
		var playerRotation = _head.global_transform.basis.z.normalized()
		
		snowball_ins.apply_central_impulse(playerRotation * force + Vector3(0, upDirection, 0))

func _on_ItemUseTimer_timeout():
	can_throw = true


func activate():
	if held_fish:
		held_fish.drop()
		held_fish = null
		return

	if not _raycast.is_colliding():
		return

	var hit = _raycast.get_collider()
	if hit == null:
		return

	var item = hit.get_parent()
	if item and item.has_method("pick_up"):
		hide_current_prompt()
		held_fish = item
		item.pick_up(_player_camera)

func _unhandled_input(event):
	if event.is_action_pressed("interact"):
		activate()


func slap():
	if slapping:
		return

	slapping = true
	var swing = create_tween()
	swing.tween_property(held_fish, "rotation_degrees:y", 180.0 + 65.0, 0.10)
	swing.tween_property(held_fish, "rotation_degrees:y", 180.0, 0.18)

	_raycast.force_raycast_update()
	var target = _raycast.get_collider()

	if target is RigidBody3D and _raycast.global_position.distance_to(_raycast.get_collision_point()) < 2.5:
		target.apply_central_impulse(-_raycast.global_basis.z * 8.0)

	await swing.finished
	slapping = false
