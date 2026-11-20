extends Interactable

@onready var body: RigidBody3D = $RigidBody3D
@onready var replicator: FusionSharedReplicator = %Replicator

var old_layer: int
var old_mask: int
var hand: Marker3D

func _ready() -> void:
	if replicator.has_authority():
		replicator.want_authority(false)

func _process(delta: float) -> void:
	if is_instance_valid(hand) and replicator.has_authority():
		body.global_transform = hand.global_transform

func pick_up(new_hand: Marker3D) -> void:
	print("Picked up fish")
	replicator.want_authority(true)
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
	print("Dropped fish")
	replicator.want_authority(false)

	if is_instance_valid(hand):
		hand = null
		body.collision_layer = old_layer
		body.collision_mask = old_mask
		body.freeze = false
