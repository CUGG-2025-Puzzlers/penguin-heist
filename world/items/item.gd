extends Node

@onready var prompt: Label3D = %Label3D

func interact():
	queue_free()
	
func show_prompt():
	prompt.visible = true
	
func hide_prompt():
	prompt.visible = false
