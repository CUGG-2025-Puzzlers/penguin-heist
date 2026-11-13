extends Menu

@onready var _display_name_label_spawner: FusionSpawner = %DisplayNameLabelSpawner
@onready var _room_code_label: Label = %RoomCodeLabel
@onready var _start_game_button: Button = %StartGameButton
@onready var _leave_game_button: Button = %LeaveGameButton

const ROOM_CODE_NOT_IN_ROOM: String = "Not In Room..."
const ROOM_CODE_PREFIX     : String = "Room Code:"

func _ready() -> void:
	if Fusion.is_master_client():
		_enable_start_button()
	
	_leave_game_button.pressed.connect(_on_leave_game_pressed)
	Fusion.player_left.connect(_on_player_left)
	
	_spawn_local_player_label()
	_set_room_code_label_text()

#region Event Handlers

func _on_player_left(_player_id: int, _is_inactive: bool) -> void:
	if Fusion.is_master_client():
		print("[%s] I am the Master Client now!" % GameSettings.display_name)
		_enable_start_button()

func _on_start_game_pressed() -> void:
	pass

func _on_leave_game_pressed() -> void:
	Fusion.leave_room()

#endregion

func _enable_start_button() -> void:
	_start_game_button.visible = true
	_start_game_button.pressed.connect(_on_start_game_pressed)

func _spawn_local_player_label() -> void:
	var display_name_label: Label = _display_name_label_spawner.spawn() as Label
	display_name_label.text = GameSettings.display_name

func _set_room_code_label_text() -> void:
	if not Fusion.is_in_room():
		_room_code_label.text = ROOM_CODE_NOT_IN_ROOM
		return
	
	var room_code: String = Fusion.get_room().room_name
	_room_code_label.text = "%s %s" % [ROOM_CODE_PREFIX, room_code]
