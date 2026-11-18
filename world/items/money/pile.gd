extends Item

@export var count : int = 5

func _ready() -> void:
	pass # Replace with function body.

## Emits a signal that a menu was requested to be closed.
func request_menu_close() -> void:
	print("Requesting to close current menu")
	pick_up()

func interact():
	count -= 1
	
	if (count <= 0):
		Fusion.free()
