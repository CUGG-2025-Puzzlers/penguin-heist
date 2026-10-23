class_name Player
extends Node3D

var display_name: String

func _ready() -> void:
	display_name = GameSettings.display_name
	name = "[P] %s" % display_name
