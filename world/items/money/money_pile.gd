extends Interactable

@onready var _held_item_spawner: FusionSpawner = %HeldItemSpawner
@export var count : int = 5
@export var cash : Node

func interact():
	count -= 1
	
	if (count <= 0):
		Fusion.free()
	
	""""""
	cash = _held_item_spawner.spawn(_held_item_spawner.get_spawnable_scene(0)) #TODO: Index properly
	cash.freeze = true
	cash.collision_layer = 0
	cash.collision_mask = 0
	cash.position = Vector3.ZERO
	cash.rotation = Vector3.ZERO

	cash.reparent(camera)
	position = Vector3(0.45, -0.4, -0.8)
	rotation = Vector3.ZERO
	rotation_degrees.y = 180

func drop():
	var camera = get_parent()
	reparent(get_tree().current_scene)
	global_position = camera.global_position - camera.global_basis.z * 1.5 - camera.global_basis.y * 0.4
	cash.collision_layer = 1
	cash.collision_mask = 1
	cash.freeze = false


@onready var _replicator: FusionSharedReplicator = %Replicator

var _spawner: FusionSpawner = null

#region Node Overrides

func _ready() -> void:
	body_entered.connect(_on_body_entered)

#endregion

#region Event Handlers

func _on_body_entered(_body: Node) -> void:
	if not Fusion.is_connected_to_photon() or not _spawner:
		queue_free()
		return
	
	if not _replicator.has_authority():
		return
	
	_spawner.despawn(self)

#endregion

func set_spawner(spawner: FusionSpawner) -> void:
	_spawner = spawner

func launch(direction: Vector3) -> void:
	apply_central_impulse(direction * launch_speed)
