extends RigidBody3D

@onready var camera : Camera3D = %RagdollCamera
@onready var face : Node3D = %Face

func _ready() -> void:
	face.visible = false
