class_name UIDs

enum Menu {
	CONNECTION,
	ROOM_SELECT,
	GAME_LOBBY,
}

const Menus: Dictionary[UIDs.Menu, String] = {
	Menu.CONNECTION:  "uid://clxo8x302tukc",
	Menu.ROOM_SELECT: "uid://dphcww3y0p1vw",
	Menu.GAME_LOBBY:  "uid://b2wpsmtwpciir",
}

enum Map {
	GAME_LOBBY,
}

const Maps: Dictionary[UIDs.Map, String] = {
	Map.GAME_LOBBY: "uid://dgjirdpi6fp3n",
}
