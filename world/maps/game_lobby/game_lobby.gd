extends Map

@onready var _spawn_points: Array[Marker3D] = [
	%Spawn1,
	%Spawn2,
	%Spawn3,
	%Spawn4,
]

func _ready() -> void:
	var spawn_index = randi() % _spawn_points.size()
	var spawn_pos = _spawn_points[spawn_index].position
	GlobalEvents.request_player_spawn(spawn_pos)
