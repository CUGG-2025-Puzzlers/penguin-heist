# Autoload
extends Node

#region Map Change

signal map_change_requested(map_id: Map.ID)
signal map_changed()

## Emits a signal that a map change was requested.
func request_map_change(map_id: Map.ID) -> void:
	var map_name: String = Map.ID.find_key(map_id).capitalize()
	print("Requesting map change to `%s`" % map_name)
	map_change_requested.emit(map_id)

## Emits a signal that a map change request was completed.
func complete_map_change() -> void:
	print("Map change completed")
	map_changed.emit()

#endregion

#region Menu Open/Close

signal menu_open_requested(menu_id: Menu.ID)
signal menu_opened()

## Emits a signal that a menu was requested to be opened.
func request_menu_open(menu_id: Menu.ID) -> void:
	var menu_name: String = Menu.ID.find_key(menu_id).capitalize()
	print("Requesting to open menu `%s`" % menu_name)
	menu_open_requested.emit(menu_id)

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

#region Player Events

signal player_spawn_requested(pos: Vector3)

func request_player_spawn(pos: Vector3) -> void:
	print("Requesting to spawn player")
	player_spawn_requested.emit(pos)

signal snowball_throw_requested(spawn_marker: Marker3D)

func request_snowball_throw(spawn_marker: Marker3D) -> void:
	print("Requesting to throw a snowball")
	snowball_throw_requested.emit(spawn_marker)

#endregion

#region HUD Show/Hide

signal add_hud_requested(hud_id: HUD.ID)
signal remove_hud_requested(hud_id: HUD.ID)
signal remove_all_hud_requested()

func request_add_hud(hud_id: HUD.ID) -> void:
	var hud_name: String = HUD.ID.find_key(hud_id).capitalize()
	print("Requesting to add HUD `%s`" % hud_name)
	add_hud_requested.emit(hud_id)

func request_remove_hud(hud_id: HUD.ID) -> void:
	var hud_name: String = HUD.ID.find_key(hud_id).capitalize()
	print("Requesting to remove HUD `%s`" % hud_name)
	remove_hud_requested.emit(hud_id)

func request_remove_all_hud() -> void:
	print("Requesting to remove all HUD")
	remove_all_hud_requested.emit()

#endregion
