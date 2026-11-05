extends Node3D
@onready var raycast = %InteractRay

var current_interactable = null

var canThrow = true

var snowball = preload("res://world/items/snowball/snowball.tscn")


func _physics_process(delta):
	check_hover_collision()
	
	snowballThrow()

func check_hover_collision():
	if raycast.is_colliding():
		var hover_collider = raycast.get_collider()
		if hover_collider and is_instance_valid(hover_collider) and hover_collider.has_method("interact") and hover_collider.has_method("show_prompt"):
			if current_interactable != hover_collider:
				if current_interactable:
					current_interactable.hide_prompt()
				current_interactable = hover_collider
				current_interactable.show_prompt()
		else:
			hide_current_prompt()
	else:
		hide_current_prompt()

func hide_current_prompt():
	if current_interactable:
		current_interactable.hide_prompt()
		current_interactable = null


func snowballThrow():
	if Input.is_action_just_released("input_throw") && canThrow:
		var snowballins = snowball.instantiate()
		snowballins.position = $ProtoController/Head/snowballpos.global_position
		get_tree().current_scene.add_child(snowballins)
		
		canThrow = false
		$ProtoController/item_use_timer.start()
		
		var force = -18
		var upDirection = 3.5
		
		var playerRotation = $ProtoController/Head.global_transform.basis.z.normalized()
		
		snowballins.apply_central_impulse(playerRotation * force + Vector3(0, upDirection, 0))


func _on_item_use_timer_timeout():
	canThrow = true
