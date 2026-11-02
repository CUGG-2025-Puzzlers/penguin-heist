class_name RoomManager
extends Node

const ERROR_DUPLICATE_IDS: String = "Error adding player to list: A player with "\
									+ "the given ID already exists."

var players: Dictionary[int, String]

func _ready() -> void:
	Fusion.player_joined.connect(_on_player_joined)
	pass

func _on_player_joined(player_id: int, user_id: String) -> void:
	await GlobalEvents.player_created
	pass

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
