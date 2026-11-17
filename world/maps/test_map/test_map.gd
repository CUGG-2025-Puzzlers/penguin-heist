extends Map

@onready var _spawn_money_point: Marker3D = %SpawnMoneyPile

func _ready() -> void:
	var spawn_money_pos = _spawn_money_point.position
	GlobalEvents.request_money_spawn(spawn_money_pos)
