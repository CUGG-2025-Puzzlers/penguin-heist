extends Menu

@onready var _display_name_label_spawner: FusionSpawner = %DisplayNameLabelSpawner

func _ready() -> void:
	_spawn_local_player_label()

func _spawn_local_player_label() -> void:
	var display_name_label: Label = _display_name_label_spawner.spawn() as Label
	display_name_label.text = GameSettings.display_name
