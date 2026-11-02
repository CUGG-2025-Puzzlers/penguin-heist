class_name Player
extends Node3D

@onready var _fusion_shared_replicator = %FusionSharedReplicator

var display_name: String

func _ready() -> void:
	if not _fusion_shared_replicator.has_authority():
		return
	
	display_name = GameSettings.display_name
	name = "[P] %s" % display_name
