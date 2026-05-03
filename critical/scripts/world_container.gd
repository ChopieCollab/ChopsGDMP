extends Node

var current_map

func _ready() -> void:
	GameManager.ChangeMap.connect(_changeMap)

func _changeMap(MapPath):
	if !multiplayer.is_server(): #Server ONLY always.
		return
	for child in self.get_children(): #Remove old level
		self.remove_child(child)
		child.queue_free()
	current_map = load(MapPath).instantiate()
	GameManager.gamestate_packed = current_map.default_gamemode.game_state
	GameManager.gamemode_packed = current_map.default_gamemode
	self.add_child(current_map) #Add new level
