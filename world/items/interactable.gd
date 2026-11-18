extends Node3D
class_name Interactable

@onready var prompt: Label3D = %Label3D

func show_prompt():
	prompt.visible = true
	
func hide_prompt():
	prompt.visible = false
