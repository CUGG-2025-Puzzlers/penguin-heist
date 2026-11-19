class_name Snowball
extends RigidBody3D

@export var launch_speed: float = 1

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
