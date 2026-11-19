@abstract
class_name Map
extends Node3D

@export var _player_spawn_markers: Array[Marker3D]

enum ID {
	NONE,
	TEST,
	GAME_LOBBY,
}

func _ready() -> void:
	GlobalEvents.request_player_spawn(_get_spawn_position())

func _get_spawn_position() -> Vector3:
	if _player_spawn_markers.size() == 0:
		push_warning("No spawn markers set for this map, players will spawn at the origin")
		return Vector3.ZERO
	
	var index = randi() % _player_spawn_markers.size()
	return _player_spawn_markers[index].global_position
