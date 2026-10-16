extends Menu

@onready var _display_name_input: LineEdit = %DisplayNameInput
@onready var _connect_button:     Button   = %ConnectButton

func _ready() -> void:
	_connect_button.pressed.connect(_on_connect_button_pressed)
	
	_display_name_input.text = GameSettings.display_name

## Event Handler for when the connect button is pressed
## Validates the display name and attempts to connect to
## the game server with that display name.
func _on_connect_button_pressed() -> void:
	if not _validate_display_name():
		# TODO: Show validation error to user
		return
	
	_set_display_name()
	ConnectionManager.connect_to_photon()

## Validates the display name input based on the following:
## - TODO: Add validation
func _validate_display_name() -> bool:
	return true

## Sets the users display name in the settings and saves it
func _set_display_name() -> void:
	GameSettings.display_name = _display_name_input.text
	GameSettings.save_user_settings()
