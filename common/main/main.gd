extends Node

# World Roots
@onready var _map_root    : Node3D = %MapRoot
@onready var _entity_root : Node3D = %EntityRoot
@onready var _players_root: Node3D = %PlayersRoot

# UI Roots
@onready var _hud_root       : Control = %HUDRoot
@onready var _transition_root: Control = %TransitionRoot
@onready var _menu_root      : Control = %MenuRoot
@onready var _debug_root     : Control = %DebugRoot

@onready var _player_spawner: FusionSpawner = %PlayerSpawner

var _current_map : Map
var _current_menu: Menu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalEvents.map_change_requested.connect(_on_map_change_requested)
	GlobalEvents.menu_open_requested.connect(_on_menu_open_requested)
	GlobalEvents.menu_close_requested.connect(_on_menu_close_requested)
	GlobalEvents.player_spawn_requested.connect(_on_player_spawn_requested)
	GlobalEvents.show_hud_requested.connect(_on_show_hud_requested)
	
	# TODO: Load main menu when not debugging
	_load_menu(UIDs.Menus[UIDs.Menu.CONNECTION])

#region Event Handlers

## Event Handler for when a map change is requested.[br]
## Attempts to load the map given by [param map_uid]
func _on_map_change_requested(map_uid: String) -> void:
	print("Map change request accepted. Attempting to load map %s" % map_uid)
	_load_map(map_uid)

## Event Handler for when a menu is requested to be opened.[br]
## Attempts to open the menu given by [param menu_uid]
func _on_menu_open_requested(menu_uid: String) -> void:
	print("Menu open request accepted. Attempting to open menu %s" % menu_uid)
	_load_menu(menu_uid)

## Event Handler for when a menu is requested to be closed.[br]
## Attempts to close the current menu
func _on_menu_close_requested() -> void:
	print("Menu close request accepted. Attempting to close current menu")
	_close_menu()

func _on_player_spawn_requested(pos: Vector3) -> void:
	print("Player spawn request accepted. Spawning player")
	_spawn_player(pos)

func _on_show_hud_requested(hud_uid: String) -> void:
	print("Show HUD request accepted. Attempting to show HUD %s" % hud_uid)
	_show_hud(hud_uid)

#endregion

## Loads a new map in the world
func _load_map(map_uid: String) -> void:
	_deferred_load_map.call_deferred(map_uid)

## Does the actual map loading during idle time
func _deferred_load_map(map_uid: String) -> void:
	# Remove the current map
	if _current_map != null:
		_current_map.queue_free()
		_current_map = null
		await get_tree().process_frame
	
	# Load the next map
	var new_map: PackedScene = ResourceLoader.load(map_uid) as PackedScene
	if new_map == null:
		var error: String = "Could not load map %s as PackedScene" % map_uid
		push_error(error)
		print(error)
		return
	
	# Instantiate the new scene
	_current_map = new_map.instantiate() as Map
	if _current_map == null:
		var error: String =\
			"Loaded map %s is not of type Map or does not exist" % map_uid
		push_error(error)
		print(error)
		return
	
	_map_root.add_child(_current_map)
	await get_tree().process_frame
	
	# TODO: Start map music
	
	GlobalEvents.complete_map_change()

## Loads a menu on top of the current scene (if there is one).[br]
## Restricted to only one menu loaded at any one time (i.e. no stacked menus)
func _load_menu(menu_uid: String) -> void:
	if _current_menu != null:
		var error: String =\
			"Could not load menu %s: Another menu is already open" % menu_uid
		push_error(error)
		print(error)
		return
	
	var menu_scene: PackedScene = ResourceLoader.load(menu_uid) as PackedScene
	if menu_scene == null:
		var error: String = "Could not load menu %s as a packed scene" % menu_uid
		push_error(error)
		print(error)
		return
	
	_current_menu = menu_scene.instantiate() as Menu
	if _current_menu == null:
		var error: String =\
			"Loaded menu %s does not extend Menu or does not exist" % menu_uid
		push_error(error)
		print(error)
		return
	
	_menu_root.add_child(_current_menu)
	
	# TODO: Pause or lower level music
	
	GlobalEvents.complete_menu_open()

## Closes the current menu and returns to control to the current scene
func _close_menu() -> void:
	if _current_menu == null:
		var error: String = "Could not close menu: No menu is currently open"
		push_error(error)
		print(error)
		return
	
	_current_menu.queue_free()
	await get_tree().process_frame
	# TODO: Resume or raise level music
	
	GlobalEvents.complete_menu_close()

func _spawn_player(pos: Vector3) -> void:
	var player = _player_spawner.spawn() as Node3D
	
	if player == null:
		print("Error spawning player")
		return
	
	player.position = pos

func _show_hud(hud_uid: String) -> void:
	var hud_scene: PackedScene = ResourceLoader.load(hud_uid) as PackedScene
	if hud_scene == null:
		var error: String = "Could not load HUD %s as a packed scene" % hud_uid
		push_error(error)
		print(error)
		return
	
	var hud_instance = hud_scene.instantiate() as HUD
	if hud_instance == null:
		var error: String =\
			"Loaded menu %s does not extend HUD or does not exist" % hud_uid
		push_error(error)
		print(error)
		return
	
	_hud_root.add_child(hud_instance)
