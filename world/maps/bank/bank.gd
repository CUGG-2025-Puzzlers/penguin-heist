extends Map

@export var round_time : int

@onready var _round_timer : Timer = %RoundTimer

var seconds_left : int

func _ready() -> void:
	super._ready()
	
	if Fusion.is_master_client():
		seconds_left = round_time
		_round_timer.start(round_time)

func _process(_delta: float) -> void:
	if Fusion.is_master_client():
		seconds_left = ceili(_round_timer.time_left)
