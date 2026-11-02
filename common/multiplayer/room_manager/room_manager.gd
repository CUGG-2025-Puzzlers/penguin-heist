class_name RoomManager
extends Node

const ERROR_DUPLICATE_IDS: String = "Error adding player to list: A player with "\
									+ "the given ID already exists."

var players: Dictionary[int, String]

func _ready() -> void:
	Fusion.player_joined.connect(_on_player_joined)
	Fusion.player_left.connect(_on_player_left)

func _on_player_joined(player_id: int, _user_id: String) -> void:
	print("[RoomManager] Player joined!")
	var player_data: Array = await GlobalEvents.player_created
	
	add_player_to_list(player_id, player_data[1])

func _on_player_left(player_id: int, is_inactive: bool) -> void:
	if is_inactive:
		# TODO: Set some inactive state flag
		return
	
	print("[RoomManager] Player left!")
	remove_player_from_list(player_id)

## Adds the given player's info to the room's player list
func add_player_to_list(player_id: int, display_name: String) -> void:
	if players.has(player_id):
		print("%s (Player %d is %s)" % [ERROR_DUPLICATE_IDS, player_id, players[player_id]])
		return
	
	print("Adding '%s' to player list" % display_name)
	players[player_id] = display_name
	GlobalEvents.complete_player_list_update()

## Removes the given player from the player list
func remove_player_from_list(player_id: int) -> void:
	print("Removing '%s' from player list" % players[player_id])
	players.erase(player_id)
	GlobalEvents.complete_player_list_update()
