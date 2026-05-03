class_name GamestateBase
extends Node

@export var ResetOnReload: bool = true ## If we want to delete this node and re-make it upon getting a new copy of it (think reloading the map by restarting it)
# Note that you could handle "resetting" of rounds without respawning the entire map... which may be (and likely is) more optimal!
# this is just here in case you want to keep the game state persistent across map changes. [In which case, set it to false]

func _ready():
	# I'm forcing the authority to the server just in case you guys try to be crazy
	set_multiplayer_authority(1)

## The Gamestate is going to be synchronized to all clients and accessible via the GameManager.active_gamestate.
## You should NOT put custom game logic in here, but rather put in scores, states of the game, etc.
## Like how the UI might need to know the score of the two teams fighting, that could be optimally stored here.
## The calculations are handled on the server, and this gamestate is synchronized so the clients can see whats happenin in the game.
## Add a synchronizer 

## Example:
#enum MatchState {LOBBY, STARTING, PLAYING, ENDING}
#var current_state : MatchState = MatchState.LOBBY # default state

### NOTICE:
## You should be using MultiplayerSynchronizers (Default to Godot) for data that doesn't need to be apart of rollback code.
## Like for example, match timers, team scores, the status of the match, etc. That's not really too important to care ab rollback.
## BUT if for whatever reason you are having variables in the game state (for some reason???) that affect player movement or physics
## you should be using the Netfox StateSynchronizer. Like if you had the game state for some reason set the gravity? Idk. Something to note.
