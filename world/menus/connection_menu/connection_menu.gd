extends Menu

@onready var _display_name_input: LineEdit = %DisplayNameInput
@onready var _connect_button:     Button   = %ConnectButton
@onready var _error_label:        Label    = %ErrorLabel

const ERROR_INVALID_DISPLAY_NAME = "Display Name is invalid"
const ERROR_CONNECTION_FAILED    = "Failed to connect to server"

func _ready() -> void:
	_connect_button.pressed.connect(_on_connect_button_pressed)
	Fusion.connection_failed.connect(_on_connection_failed)
	
	_display_name_input.text = GameSettings.display_name
	_connect_button.disabled = false
	_error_label.text = ""

#region Photon Event Handlers

func _on_connection_failed(error: String) -> void:
	_error_label.text = "%s: %s" % [ERROR_CONNECTION_FAILED, error]
	_connect_button.disabled = false

#endregion

## Event Handler for when the connect button is pressed
## Validates the display name and attempts to connect to
## the game server with that display name.
func _on_connect_button_pressed() -> void:
	if not _validate_display_name():
		_error_label.text = ERROR_INVALID_DISPLAY_NAME
		return
	
	_error_label.text = ""
	_connect_button.disabled = true
	
	_set_display_name()
	ConnectionManager.connect_to_photon()

## Validates the display name input based on the following:
## - Length between 2 and 15 characters
## - TODO: Add validation
func _validate_display_name() -> bool:
	var length: int = len(_display_name_input.text.strip_edges())
	if length < 2 or length > 15:
		return false
	
	return true

## Sets the users display name in the settings and saves it
func _set_display_name() -> void:
	var formatted_name: String = _display_name_input.text.strip_edges()
	
	if GameSettings.display_name == formatted_name:
		return
	
	GameSettings.display_name = formatted_name
	GameSettings.save_user_settings()
