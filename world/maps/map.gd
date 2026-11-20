@abstract
class_name Map
extends Node3D

@export var _player_spawn_markers: Array[Marker3D]
@export var _fish_spawn_markers: Array[Marker3D]
@export var _money_spawn_markers: Array[Marker3D]

enum ID {
	NONE,
	TEST,
	GAME_LOBBY,
	Bank,
}

func _ready() -> void:
	# Requests that the player be spawned once the map is added to the tree
	var player_spawn_pos = _get_random_spawn_position(_player_spawn_markers)
	GlobalEvents.request_player_spawn(player_spawn_pos)
	if (Fusion.is_master_client()):
		_spawn_fish()
		_spawn_money_pile()

## Returns the position of a random Marker3D from the given list
## Returns Vector3.Zero if there are no markers to choose from
func _get_random_spawn_position(markers: Array[Marker3D]) -> Vector3:
	if markers.size() == 0:
		return Vector3.ZERO
	
	var index = randi() % markers.size()
	return markers[index].global_position

func _spawn_fish() -> void:
	var i = 1
	for fish_spawn_marker in _fish_spawn_markers:
		print("Spawning fish #" + str(i))
		GlobalEvents.request_fish_spawn(fish_spawn_marker.global_position)
		i += 1

func _spawn_money_pile() -> void:
	var i = 1
	for money_spawn_marker in _money_spawn_markers:
		print("Spawning money pile #" + str(i))
		GlobalEvents.request_money_spawn(money_spawn_marker.global_position)
		i += 1
