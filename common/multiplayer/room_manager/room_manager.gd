class_name RoomManager
extends Node

const ERROR_DUPLICATE_IDS = "Error adding player to list: A player with the given 
							ID already exists."

var players: Dictionary[int, PlayerInfo]

func _ready() -> void:
	pass

## Adds the given player's info to the room's player list
func add_player_to_list(player_id: int, info: PlayerInfo) -> void:
	if players.has(player_id):
		print("%s (Player %d is %s)" % [ERROR_DUPLICATE_IDS, player_id, players[player_id].display_name])
		return
	
	print("Adding '%s' to player list" % info.display_name)
	players[player_id] = info

## Removes the given player from the player list
func remove_player_from_list(player_id: int) -> void:
	print("Removing '%s' from player list" % players[player_id].display_name)
	players.erase(player_id)
