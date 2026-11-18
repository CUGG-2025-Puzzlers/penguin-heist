extends Interactable

@onready var _held_item_spawner: FusionSpawner = %HeldItemSpawner

var body: RigidBody3D = Fusion.
var old_layer: int
var old_mask: int

func pick_up(camera: Camera3D, Item):
	item = _held_item_spawner
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
