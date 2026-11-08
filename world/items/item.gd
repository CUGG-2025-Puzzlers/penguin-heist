extends Node3D

@onready var prompt: Label3D = %Label3D

@onready var body: RigidBody3D = $RigidBody3D
var old_layer: int
var old_mask: int
	
func show_prompt():
	prompt.visible = true
	
func hide_prompt():
	prompt.visible = false

func pick_up(camera: Camera3D):
	prompt.hide()
	old_layer = body.collision_layer
	old_mask = body.collision_mask
	body.freeze = true
	body.collision_layer = 0
	body.collision_mask = 0
	body.position = Vector3.ZERO
	body.rotation = Vector3.ZERO
	reparent(camera)
	position = Vector3(0.45, -0.4, -0.8)
	rotation = Vector3.ZERO
	rotation_degrees.y = 180

func drop():
	var camera = get_parent()
	reparent(get_tree().current_scene)
	global_position = camera.global_position - camera.global_basis.z * 1.5 - camera.global_basis.y * 0.4
	body.collision_layer = old_layer
	body.collision_mask = old_mask
	body.freeze = false
