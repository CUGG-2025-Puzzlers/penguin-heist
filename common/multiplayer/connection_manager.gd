extends Node

# This script should handle the local Client's connection
# It should not worry about remote players joining or leaving

const ROOM_CODE_CHARS: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

const ERROR_ROOM_MANAGER_NOT_IN_ROOM: String =\
	"Cannot create a Room Manager outside of a room"
const ERROR_ROOM_MANAGER_NOT_PACKED_SCENE: String =\
	"Could not load Room Manager as PackedScene"
const ERROR_ROOM_MANAGER_BAD_TYPE: String =\
	"Loaded scene is not of type Room Manager or does not exist"

var room_manager: RoomManager = null

func _ready() -> void:
	# Subscribe to Photon Events
	Fusion.connected_to_photon.connect(_on_connected_to_photon)
	Fusion.connection_failed.connect(_on_connection_failed)
	Fusion.connection_status_changed.connect(_on_connection_status_changed)
	Fusion.room_joined.connect(_on_room_joined)
	Fusion.room_left.connect(_on_room_left)

#region Photon Event Handlers

func _on_connected_to_photon() -> void:
	print("Successfully connected to Photon server as '%s'" % GameSettings.display_name)
	_change_menu(UIDs.Menu.RoomSelect)

func _on_connection_failed(error: String) -> void:
	print("Failed to connect to Photon server: %s" % error)

# 0 - DISCONNECTED (not connected)
# 1 - CONNECTING (establishing connection)
# 2 - CONNECTED (connected to Photon Cloud
# 3 - JOINING ROOM (join in progress)
# 4 - IN ROOM (in a room)
# 5 - ERROR (connection error)
func _on_connection_status_changed(status: int) -> void:
	pass

func _on_room_joined() -> void:
	print("Successfully joined room as '%s'" % GameSettings.display_name)
	
	_create_room_manager()
	_change_menu(UIDs.Menu.GameLobby)
	GlobalEvents.request_player_creation()

func _on_room_left() -> void:
	print("Left room")
	GlobalEvents.request_player_deletion()
	_change_menu(UIDs.Menu.RoomSelect)

#endregion

# (), (user_id), (user_id, region)
func connect_to_photon() -> void:
	print("Attempting to connect to Photon server")
	Fusion.connect_to_photon()

func create_room() -> void:
	var room_code: String = _generate_random_code()
	var room_options: FusionRoomOptions = FusionRoomOptions.new()
	room_options.max_players = 4
	Fusion.create_room(room_code, room_options)

func join_room(room_code: String) -> void:
	Fusion.join_room(room_code)

## Generates a random code for Room creation
func _generate_random_code() -> String:
	var code: String = ""
	var code_length: int = 5
	var chars_length: int = ROOM_CODE_CHARS.length()
	
	for i in range(code_length):
		var r = randi() % chars_length
		code += ROOM_CODE_CHARS[r]
	
	return code

## Requests to change the current menu to the given one
func _change_menu(menu: UIDs.Menu) -> void:
	GlobalEvents.request_menu_close()
	await GlobalEvents.menu_closed
	
	GlobalEvents.request_menu_open(UIDs.Menus[menu])

## Creates a room manager for the current room if this client is the master client
func _create_room_manager() -> void:
	if not Fusion.is_master_client():
		return
	
	if not Fusion.is_in_room():
		push_error(ERROR_ROOM_MANAGER_NOT_IN_ROOM)
		print(ERROR_ROOM_MANAGER_NOT_IN_ROOM)
		return
	
	var new_room_manager: PackedScene = ResourceLoader.load(UIDs.ROOM_MANAGER_UID) as PackedScene
	if new_room_manager == null:
		push_error(ERROR_ROOM_MANAGER_NOT_PACKED_SCENE)
		print(ERROR_ROOM_MANAGER_NOT_PACKED_SCENE)
		return

	room_manager = new_room_manager.instantiate() as RoomManager
	if room_manager == null:
		push_error(ERROR_ROOM_MANAGER_BAD_TYPE)
		print(ERROR_ROOM_MANAGER_BAD_TYPE)
		return

	add_child(room_manager)
	await get_tree().process_frame
