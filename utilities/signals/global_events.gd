# Autoload
extends Node

signal map_change_requested(map_uid: String)
signal menu_open_requested(menu_uid: String)
signal menu_close_requested()

## Emits a signal that a map change was requested.
func request_map_change(map_uid: String) -> void:
	print("Requesting map change to %s" % map_uid)
	map_change_requested.emit(map_uid)

## Emits a signal that a menu was requested to be opened.
func request_menu_open(menu_uid: String) -> void:
	print("Requesting to open menu %s" % menu_uid)
	menu_open_requested.emit(menu_uid)

## Emits a signal that a menu was requested to be closed.
func request_menu_close() -> void:
	print("Requesting to close current menu")
	menu_close_requested.emit()
