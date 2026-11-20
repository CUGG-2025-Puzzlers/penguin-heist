extends Interactable

@export var count : int = 5
@onready var _replicator: FusionSharedReplicator = %Replicator
var _spawner: FusionSpawner

func interact(hand: Marker3D, player: CharacterBody3D) -> void:
	count -= 1
	
	GlobalEvents.request_cash_spawn(hand, player)
	
	if count <= 0 and _replicator.has_authority():
		_spawner.despawn(self)
	
func set_spawner(spawner: FusionSpawner) -> void:
	_spawner = spawner
