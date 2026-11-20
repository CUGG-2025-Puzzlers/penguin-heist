class_name Item
extends Interactable

@onready var replicator: FusionSharedReplicator = %Replicator

var old_layer: int
var old_mask: int
var hand: Marker3D
var is_held: bool:
	set(value):
		is_held = value
		_apply_held_state()

func _ready() -> void:
	old_layer = 1
	old_mask = 1
	_apply_held_state()
	
	replicator.authority_requested.connect(_on_authority_requested)

func _process(delta: float) -> void:
	if is_instance_valid(hand) and replicator.has_authority():
		global_transform = hand.global_transform

func pick_up(new_hand: Marker3D) -> void:
	print("Picked up fish")
	replicator.want_authority(true)
	while not replicator.has_authority():
		await get_tree().process_frame
	prompt.hide()
	hand = new_hand
	is_held = true

func drop() -> void:
	print("Dropped fish")

	if is_instance_valid(hand):
		hand = null
		
	is_held = false
	replicator.want_authority(false)

func _apply_held_state() -> void:
	if is_held:
		self.freeze = true
		self.collision_layer = 0
		self.collision_mask = 0
	else:
		self.collision_layer = old_layer
		self.collision_mask = old_mask
		self.freeze = false
		
func _on_authority_requested(_id: int) -> bool:
	return not is_held
