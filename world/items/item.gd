extends Interactable

@onready var body: RigidBody3D = $RigidBody3D

var old_layer: int
var old_mask: int
var hand: Marker3D

func _process(delta: float) -> void:
	if is_instance_valid(hand):
		global_transform = hand.global_transform

func pick_up(new_hand: Marker3D) -> void:
	prompt.hide()
	old_layer = body.collision_layer
	old_mask = body.collision_mask
	body.freeze = true
	body.collision_layer = 0
	body.collision_mask = 0
	body.position = Vector3.ZERO
	body.rotation = Vector3.ZERO
	hand = new_hand

func drop() -> void:
	if is_instance_valid(hand):
		global_position = hand.global_position - hand.global_basis.z * 1.5 - hand.global_basis.y * 0.4
		hand = null
		body.collision_layer = old_layer
		body.collision_mask = old_mask
		body.freeze = false
