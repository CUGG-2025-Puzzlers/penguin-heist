extends Node

# This script should handle the local Client's connection
# It should not worry about remote players joining or leaving

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
	pass

func _on_room_left() -> void:
	pass

#endregion

# (), (user_id), (user_id, region)
func _connect_to_photon(user_id: String) -> void:
	pass

func _create_room(room_code: String, room_options: FusionRoomOptions) -> void:
	pass

func _join_room(room_code: String, room_options: FusionRoomOptions) -> void:
	pass
