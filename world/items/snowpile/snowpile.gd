extends StaticBody3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


@onready var pickup_area: Area3D = $PickupArea


func _physics_process(_delta: float) -> void:
	for body in pickup_area.get_overlapping_bodies():
		var current_node: Node = body
		while current_node != null:
			if current_node.has_method("refill_snowballs"):
				current_node.refill_snowballs()
				break
			current_node = current_node.get_parent()

func _on_area_3d_body_entered(body: Node3D) -> void:
	pass


func _on_area_3d_body_exited(body: Node3D) -> void:
	pass # Replace with function body.
