extends Menu

@onready var _display_name_labels: Array[Label] = [
	%DisplayNameLabel1,
	%DisplayNameLabel2,
	%DisplayNameLabel3,
	%DisplayNameLabel4
]

func _ready() -> void:
	Fusion.player_joined.connect(_on_player_joined)
	Fusion.player_left.connect(_on_player_left)
	
	GlobalEvents.player_list_updated.connect(_on_player_list_updated)

func _on_player_joined(_player_id: int, _user_id: String) -> void:
	print("Player '%s' joined as P%d" % [_user_id, _player_id])

func _on_player_left(_player_id: int, is_inactive: bool) -> void:
	if is_inactive:
		print ("P%d is inactive" % _player_id)
		return
	
	print("P%d left. " % _player_id)

func _on_player_list_updated() -> void:
	clear_player_list()
	var players: Dictionary[int, String] = ConnectionManager.room_manager.players
	var index: int = 0
	for id in players.keys():
		_display_name_labels[index].text = players[id]
		index += 1
		
		if index >= 4:
			break

func clear_player_list() -> void:
	for label in _display_name_labels:
		label.text = ""
