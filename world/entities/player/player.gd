class_name Player
extends Node3D

var info: PlayerInfo

func _ready() -> void:
	info.display_name = GameSettings.display_name
	name = "[P] %s" % info.display_name
