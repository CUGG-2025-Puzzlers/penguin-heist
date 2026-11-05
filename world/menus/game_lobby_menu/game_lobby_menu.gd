extends Menu

@onready var _display_name_label_spawner: FusionSpawner = %DisplayNameLabelSpawner
@onready var _room_code_label: Label = %RoomCodeLabel

const ROOM_CODE_NOT_IN_ROOM: String = "Not In Room..."
const ROOM_CODE_PREFIX     : String = "Room Code:"

func _ready() -> void:
	_spawn_local_player_label()
	_set_room_code_label_text()

func _spawn_local_player_label() -> void:
	var display_name_label: Label = _display_name_label_spawner.spawn() as Label
	display_name_label.text = GameSettings.display_name

func _set_room_code_label_text() -> void:
	if not Fusion.is_in_room():
		_room_code_label.text = ROOM_CODE_NOT_IN_ROOM
		return
	
	var room_code: String = Fusion.get_room().room_name
	_room_code_label.text = "%s %s" % [ROOM_CODE_PREFIX, room_code]
