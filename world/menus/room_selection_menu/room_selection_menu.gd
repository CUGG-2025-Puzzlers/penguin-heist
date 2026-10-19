extends Menu

@onready var _create_room_button:      Button   = %CreateRoomButton
@onready var _create_room_error_label: Label    = %CreateErrorLabel

@onready var _room_code_input:       LineEdit = %RoomCodeInput
@onready var _join_room_button:      Button   = %JoinRoomButton
@onready var _join_room_error_label: Label    = %JoinErrorLabel

const ROOM_CODE_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

const NO_ERROR = ""

var _creating_room: bool = false
var _joining_room: bool = false

func _ready() -> void:
	_create_room_button.pressed.connect(_on_create_room_button_pressed)
	_join_room_button.pressed.connect(_on_join_room_button_pressed)
	Fusion.connection_failed.connect(_on_connection_failed)
	
	_clear_error_messages()

#region Event Handlers

func _on_connection_failed(error: String) -> void:
	if _creating_room:
		_create_room_error_label.text = error
		_enable_buttons()
		return
	
	if _joining_room:
		_join_room_error_label.text = error
		_enable_buttons()

## Event Handler for when the Create Room button is pressed.[br]
## Attempts to create and join a room
func _on_create_room_button_pressed() -> void:
	_disable_buttons()
	_creating_room = true
	
	var room_code: String = _generate_random_code()
	var room_options: FusionRoomOptions = FusionRoomOptions.new()
	room_options.max_players = 4
	Fusion.create_room(room_code, room_options)

## Event Handler for when the Join Room button is pressed.[br]
## Attempts to join a room using the code in the Room Code input
func _on_join_room_button_pressed() -> void:
	_disable_buttons()
	_joining_room = true
	
	var room_code: String = _room_code_input.text
	Fusion.join_room(room_code)

#endregion

## Clears all error messages from the menu
func _clear_error_messages() -> void:
	_create_room_error_label.text = NO_ERROR
	_join_room_error_label.text = NO_ERROR

## Enables all buttons in the menu
func _enable_buttons() -> void:
	_create_room_button.disabled = false
	_join_room_button.disabled = false

## Disables all buttons in the menu
func _disable_buttons() -> void:
	_create_room_button.disabled = true
	_join_room_button.disabled = true

## Generates a random code for Room creation
func _generate_random_code() -> String:
	var code: String = ""
	var code_length: int = 5
	var chars_length: int = ROOM_CODE_CHARS.length()
	
	for i in range(code_length):
		var r = randi() % chars_length
		code += ROOM_CODE_CHARS[r]
	
	return code
