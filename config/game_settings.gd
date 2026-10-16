extends Node

# This script should handle loading and saving player settings

# Paths
const DEFAULT_SETTINGS_PATH = "res://config/game_settings.cfg"
const USER_SETTINGS_PATH    = "user://game_settings.cfg"

# User Section Strings
const SECTION_USER = "User"
const KEY_DISPLAY_NAME = "display_name"

# User Sections attributes
var display_name: String = ""

## Load the user's settings
func _ready() -> void:
	_load_settings()

## Load the user's settings, using the default settings as a fallback 
func _load_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	
	# Try loading from user settings
	print("Loading user settings")
	var error_user: Error = config.load(USER_SETTINGS_PATH)
	if error_user != OK:
		print("Error loading user settings: %s" % error_string(error_user))
		
		# Try loading from default settings
		print("Loading default settings")
		var error_default: Error = config.load(DEFAULT_SETTINGS_PATH)
		if error_default != OK:
			# Settings can't be loaded
			print("Error loading default settings: %s" % error_string(error_default))
			return
	
	_get_settings(config)
	
	if error_user == OK:
		return
	
	# If the user settings load failed earlier, save new user settings file
	var error_save = config.save(USER_SETTINGS_PATH)
	if error_save != OK:
		print("Error saving default settings to user settings: %s" % error_string(error_save))

## Sets this class's attributes using the provided config file
func _get_settings(config: ConfigFile) -> void:
	display_name = config.get_value(SECTION_USER, KEY_DISPLAY_NAME, "")

## Saves the settings under the 'User' section
func save_user_settings() -> Error:
	var config = ConfigFile.new()
	
	# Load config file
	var error = config.load(USER_SETTINGS_PATH)
	if error != OK:
		print("Error loading user settings: %s" % error_string(error))
		return error
	
	# Update settings
	config.set_value(SECTION_USER, KEY_DISPLAY_NAME, display_name)
	
	# Save changes
	error = config.save(USER_SETTINGS_PATH)
	if error != OK:
		print("Error saving user settings: %s" % error_string(error))
		return error
	
	return OK
