# Autoload
extends Node

#region Map Change

signal map_change_requested(map_uid: String)
signal map_changed()

## Emits a signal that a map change was requested.
func request_map_change(map_uid: String) -> void:
	print("Requesting map change to %s" % map_uid)
	map_change_requested.emit(map_uid)

## Emits a signal that a map change request was completed.
func complete_map_change() -> void:
	print("Map change completed")
	map_changed.emit()

#endregion

#region Menu Open/Close

signal menu_open_requested(menu_uid: String)
signal menu_opened()

## Emits a signal that a menu was requested to be opened.
func request_menu_open(menu_uid: String) -> void:
	print("Requesting to open menu %s" % menu_uid)
	menu_open_requested.emit(menu_uid)

## Emits a signal that a menu open request was completed.
func complete_menu_open() -> void:
	print("Menu opened successfully")
	menu_opened.emit()

signal menu_close_requested()
signal menu_closed()

## Emits a signal that a menu was requested to be closed.
func request_menu_close() -> void:
	print("Requesting to close current menu")
	menu_close_requested.emit()

## Emits a signal that a menu close request was completed.
func complete_menu_close() -> void:
	print("Menu closed successfully")
	menu_closed.emit()

#endregion

#region Player Spawning

signal player_creation_requested()
signal player_created(player_id: int, info: PlayerInfo)

## Emits a signal that a new player object was requested to be created
func request_player_creation() -> void:
	player_creation_requested.emit()

## Emits a signal that a player creation request was completed
func complete_player_creation(player_id: int, info: PlayerInfo) -> void:
	player_created.emit(player_id, info)

signal player_deletion_requested()
signal player_deleted(player_id: int)

## Emits a signal that an existing player object was requested to be deleted
func request_player_deletion() -> void:
	player_deletion_requested.emit()

## Emits a signal that a player deletion request was completed
func complete_player_deletion(player_id: int) -> void:
	player_deleted.emit(player_id)

#region
