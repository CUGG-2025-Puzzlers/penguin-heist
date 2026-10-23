extends Menu

@onready var _player_list: Array[Label] = [
	%DisplayNameLabel1,
	%DisplayNameLabel2,
	%DisplayNameLabel3,
	%DisplayNameLabel4
]

func _ready() -> void:
	Fusion.player_joined.connect(_on_player_joined)
	Fusion.player_left.connect(_on_player_left)

func _on_player_joined(_player_id: int, _user_id: String) -> void:
	print("Player '%s' joined as P%d" % [_user_id, _player_id])
	pass

func _on_player_left(_player_id: int, is_inactive: bool) -> void:
	print("P%d left. " % _player_id)
	pass
