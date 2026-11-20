extends Interactable

@export var count : int = 5
@onready var _replicator: FusionSharedReplicator = %Replicator
var _spawner: FusionSpawner

func interact(hand: Marker3D, player: CharacterBody3D) -> void:
	GlobalEvents.request_cash_spawn(hand, player)
	
	if _replicator.has_authority():
		count -= 1
		if count <= 0:
			_spawner.despawn(self)
	else:
		Fusion.rpc_to_player(_replicator.get_owner_id(), take_cash)
	
func set_spawner(spawner: FusionSpawner) -> void:
	_spawner = spawner

@rpc("any_peer", "call_remote", "reliable")
func take_cash():
	count -= 1
	if count <= 0:
		_spawner.despawn(self)
