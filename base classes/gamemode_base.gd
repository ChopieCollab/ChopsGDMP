@tool
class_name GamemodeBase
extends Node

@export_category("GM Main Settings")
@export var gamemode_name: String = "Forgor To Name"
@export var default_pawn: PackedScene:
	set(value):
		default_pawn = value
		_validate_scene()
#@export var default_hud: String = "Forgor To Name" Not used for now. May use later.
@export var default_spectator: PackedScene:
	set(value):
		default_spectator = value
		_validate_scene()
@export var game_state: PackedScene:
	set(value):
		game_state = value
		_validate_scene()

@export_category("GM Sub-Settings")
@export var SpawnOnConnect: bool = true ## Spawn a default pawn on the client connecting? (I recommend you spawn SOMETHING.)
@export var SpawnOnConnectChannel: int = 0 ## The default player spawn channel to use when doing the above default connection spawning behavior.
@export var RemakePawnsOnMapChange: bool = true ## When changing maps, the player handler checks this to see if it should remove all the players and then respawn them. If you want to do custom spawn logic, check out the comment below.
@export var RespawnDefaultChannel: int = 0 ## The default player spawn channel to use when doing the above default respawn behavior.
# If you want to have custom spawn logic, like for example maybe the players don't actually despawn but instead they get moved to another scene,
# you could keep the players, possibly freeze them, then in the gamemode teleport them all
# But if you wanted to have them respawn at specific channels, you would need to call the functions manually in your gamemode.
# GameManager.Main_Root.players would be the reference to the player manager. You could for example do this:
# GameManager.Main_Root.players.despawnAll()
# var playerIDlist = multiplayer.get_peers()
# for playerID in playerIDlist: GameManager.Main_Root.players._spawn_player(playerID, [insert what channel you want this player to spawn at], [the pawn you want them to get when they spawn there])
# Just make sure you actually *HAVE* a spawn location for them at the specified channel. Currently the default behavior is to not set their transform, meaning
# they will simply spawn at 0, 0, 0.


func _validate_scene():
	if Engine.is_editor_hint():
		if default_pawn != null:
			var test_instance = default_pawn.instantiate()
			if !(test_instance is Pawn):
				push_error("Error: Use a pawn scene!")
				# Reset because nuhuh you better use a pawn or else
				default_pawn = null 
			test_instance.free()
		
		if default_spectator != null:
			var test_instance = default_spectator.instantiate()
			if !(test_instance is Pawn):
				push_error("Error: Use a pawn scene!")
				default_spectator = null 
			test_instance.free()
		
		if game_state != null:
			var test_instance = game_state.instantiate()
			if !(test_instance is GamestateBase):
				push_error("Error: Use a gamestate scene!")
				game_state = null 
			test_instance.free()
