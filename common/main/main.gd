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

# Network Spawners
@onready var _player_spawner  : FusionSpawner = %PlayerSpawner
@onready var _snowball_spawner: FusionSpawner = %SnowballSpawner

var _current_map : Map
var _current_menu: Menu
var _active_huds : Dictionary[HUD.ID, HUD]

#region Node Overrides

func _ready() -> void:
	GlobalEvents.map_change_requested.connect(_on_map_change_requested)
	
	GlobalEvents.menu_open_requested.connect(_on_menu_open_requested)
	GlobalEvents.menu_close_requested.connect(_on_menu_close_requested)
	
	GlobalEvents.add_hud_requested.connect(_on_add_hud_requested)
	GlobalEvents.remove_hud_requested.connect(_on_remove_hud_requested)
	GlobalEvents.remove_all_hud_requested.connect(_on_remove_all_hud_requested)
	
	GlobalEvents.player_spawn_requested.connect(_on_player_spawn_requested)
	GlobalEvents.snowball_throw_requested.connect(_on_snowball_throw_requested)
	
	# TODO: Load main menu when not debugging
	_load_menu(Menu.ID.CONNECTION)

#endregion

#region Event Handlers

## Event Handler for when a map change is requested.[br]
## Attempts to load the map given by [param map_id]
func _on_map_change_requested(map_id: Map.ID) -> void:
	var map_name: String = Map.ID.find_key(map_id).capitalize()
	print("Map change request accepted. Attempting to load map `%s`" % map_name)
	_load_map(map_id)

## Event Handler for when a menu is requested to be opened.[br]
## Attempts to open the menu given by [param menu_id]
func _on_menu_open_requested(menu_id: Menu.ID) -> void:
	var menu_name: String = Menu.ID.find_key(menu_id).capitalize()
	print("Menu open request accepted. Attempting to open menu `%s`" % menu_name)
	_load_menu(menu_id)

## Event Handler for when a menu is requested to be closed.[br]
## Attempts to close the current menu
func _on_menu_close_requested() -> void:
	print("Menu close request accepted. Attempting to close current menu")
	_close_menu()

## Event Handler for when a HUD is requested to be added.[br]
## Attempts to add the HUD given by [param hud_id]
func _on_add_hud_requested(hud_id: HUD.ID) -> void:
	var hud_name: String = HUD.ID.find_key(hud_id).capitalize()
	print("Add HUD request accepted. Attempting to add HUD `%s`" % hud_name)
	_add_hud(hud_id)

## Event Handler for when a HUD is requested to be removed.[br]
## Attempts to remove the HUD given by [param hud_id]
func _on_remove_hud_requested(hud_id: HUD.ID) -> void:
	var hud_name: String = HUD.ID.find_key(hud_id).capitalize()
	print("Remove HUD request accepted. Attempting to remove HUD `%s`" % hud_name)
	_remove_hud(hud_id)

## Event Handler for when all HUDs are requested to be removed.[br]
## Attempts to remove all HUDs
func _on_remove_all_hud_requested() -> void:
	print("Remove all HUD request accepted. Attempting to remove all HUDs")
	_remove_all_hud()

## Event Handler for when the local player is requested to be spawned.[br]
## Attempts to spawn the player at the position given [param pos]
func _on_player_spawn_requested(pos: Vector3) -> void:
	print("Player spawn request accepted. Spawning player")
	_spawn_player(pos)

## Event Handler for when a snowball is requested to be thrown.[br]
## Attempts to spawn and throw the snowball from the marker given by 
## [param spawn_marker]
func _on_snowball_throw_requested(spawn_marker: Marker3D) -> void:
	print("Snowball throw request accepted. Throwing snowball, watch out!")
	_throw_snowball(spawn_marker)

#endregion

#region Map Functions

## Loads a new map in the world
func _load_map(map_id: Map.ID) -> void:
	_deferred_load_map.call_deferred(map_id)

## Does the actual map loading during idle time
func _deferred_load_map(map_id: Map.ID) -> void:
	# Remove the current map
	if _current_map != null:
		_current_map.queue_free()
		_current_map = null
		await get_tree().process_frame
	
	if map_id == Map.ID.NONE:
		return
	
	# Load the next map
	var map_name: String = Map.ID.find_key(map_id).capitalize()
	var map_uid: String = UIDs.Maps[map_id]
	var new_map: PackedScene = ResourceLoader.load(map_uid) as PackedScene
	if new_map == null:
		var error: String = "Could not load map `%s` as PackedScene" % map_name
		push_error(error)
		print(error)
		return
	
	# Instantiate the new scene
	_current_map = new_map.instantiate() as Map
	if _current_map == null:
		var error: String =\
			"Loaded map `%s` is not of type Map or does not exist" % map_name
		push_error(error)
		print(error)
		return
	
	_map_root.add_child(_current_map)
	await get_tree().process_frame
	
	# TODO: Start map music
	
	GlobalEvents.complete_map_change()

#endregion

#region Menu Functions

## Loads a menu on top of the current scene (if there is one).[br]
## Restricted to only one menu loaded at any one time (i.e. no stacked menus)
func _load_menu(menu_id: Menu.ID) -> void:
	var menu_name = Menu.ID.find_key(menu_id).capitalize()
	
	if _current_menu != null:
		var error: String =\
			"Could not load menu `%s`: Another menu is already open" % menu_name
		push_error(error)
		print(error)
		return
	
	var menu_uid: String = UIDs.Menus[menu_id]
	var menu_scene: PackedScene = ResourceLoader.load(menu_uid) as PackedScene
	if menu_scene == null:
		var error: String = "Could not load menu `%s` as a packed scene" % menu_name
		push_error(error)
		print(error)
		return
	
	_current_menu = menu_scene.instantiate() as Menu
	if _current_menu == null:
		var error: String =\
			"Loaded menu `%s` does not extend Menu or does not exist" % menu_name
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

#endregion

#region HUD Functions

## Loads the HUD given by [param hud_id] on top of the current scene.[br]
## Internally keeps track of open HUDs so that they can be closed later
func _add_hud(hud_id: HUD.ID) -> void:
	var hud_name: String = Menu.ID.find_key(hud_id).capitalize()
	var hud_uid: String = UIDs.HUDs[hud_id]
	var hud_scene: PackedScene = ResourceLoader.load(hud_uid) as PackedScene
	if hud_scene == null:
		var error: String = "Could not load HUD `%s` as a packed scene" % hud_name
		push_error(error)
		print(error)
		return
	
	var hud_instance = hud_scene.instantiate() as HUD
	if hud_instance == null:
		var error: String =\
			"Loaded HUD `%s` does not extend HUD or does not exist" % hud_name
		push_error(error)
		print(error)
		return
	
	_active_huds[hud_id] = hud_instance
	_hud_root.add_child(hud_instance)

## Removes the HUD given by [param hud_id] from the scene
func _remove_hud(hud_id: HUD.ID) -> void:
	if not _active_huds.has(hud_id):
		return
	
	var hud_instance = _active_huds[hud_id]
	hud_instance.queue_free()
	_active_huds.erase(hud_id)

## Removes all HUDs from the scene
func _remove_all_hud() -> void:
	for id: HUD.ID in _active_huds.keys():
		_remove_hud(id)

#endregion

#region Player Functions

## Spawns the player using the FusionSpawner to allow for networking
## Sets the player's position to the position given by [param pos]
func _spawn_player(pos: Vector3) -> void:
	var player = _player_spawner.spawn() as Node3D
	
	if player == null:
		print("Error spawning player")
		return
	
	player.position = pos

## Spawns a snowball using the FusionSpawner to allow for networking
## Sets the position to the [param spawn_marker]'s position and launches
## it in the forward direction of the marker
func _throw_snowball(spawn_marker: Marker3D) -> void:
	var snowball: Snowball = _snowball_spawner.spawn() as Snowball
		
	# TODO: Print some error if spawner did not spawn a snowball scene
	if not snowball:
		return
	
	snowball.set_spawner(_snowball_spawner)
	snowball.global_position = spawn_marker.global_position
	var launch_direction: Vector3 = -spawn_marker.global_basis.z
	snowball.launch(launch_direction)

#endregion
