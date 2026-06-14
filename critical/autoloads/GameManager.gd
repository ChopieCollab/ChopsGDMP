extends Node

var Main_Root: Node

var active_map
var active_gamemode: Node
var gamemode_packed: PackedScene: # This will presumably ONLY be changed on the server.
	set(value):
		_on_gamemode_changed(value)
var active_gamestate: Node # The gamestate should be synchronized, but the gamemode isn't because the server is running that.
var gamestate_packed: PackedScene: # This will presumably ONLY be changed on the server.
	set(value):
		_on_gamestate_changed(value)

signal ChangeMap

var GameStateSpawner: MultiplayerSpawner
var GameStateContainer: Node # this is the node for the spawned game states

func _ready() -> void:
	GameStateContainer = Node.new()
	GameStateContainer.name = "GameStateContainer"
	self.add_child(GameStateContainer)
	
	GameStateSpawner = MultiplayerSpawner.new()
	GameStateSpawner.name = "GameStateSpawner" # I'm setting the name because i want to but also because its better for MP refs
	self.add_child(GameStateSpawner) # Making a spawner for the gamestate to be synced C:
	
	GameStateSpawner.spawn_path = GameStateContainer.get_path()
	GameStateSpawner.spawn_function = _on_spawner_custom_spawn

func changeMap(MapPath: String):
	ChangeMap.emit(MapPath)

func _on_gamemode_changed(NewGamemode): # This will presumably ONLY be called on the server.
	if !multiplayer.is_server(): # but I guess JUUUUST in case...
		return
	
	## NOTICE: The Gamemode is ONLY ON THE SERVER!!!
	# we are ALWAYS going to be replacing the gamemode when we load into the map. If you want to
	# have a map that has multiple gamemodes you'll need to manually change the packed gamemode
	# personally I'd recommend making it so when you select the map you can choose the gamemode, and then adding an argument to
	# the changeMap inside the GameManager (here) OR you could also just have separate maps with different gamemodes selected.
	# which honestly could be good depending on if you want to modify the map slightly (think Wingman in CSGO)
	if active_gamemode == null:
		pass
	else:
		active_gamemode.queue_free()
	#active_gamemode
	var gm_scene = NewGamemode # NewGamemode is packed
	var instance = gm_scene.instantiate()
	self.add_child(instance)
	active_gamemode = instance #make sure we track the new one

func _on_gamestate_changed(NewGamestate): # This will presumably ONLY be called on the server.
	if !multiplayer.is_server(): # but I guess JUUUUST in case...
		return
	
	if gamestate_packed == null: # If we dont have a gamestate, make one!
		server_spawn_gamestate(NewGamestate.resource_path)
	
	if NewGamestate.resource_path == active_gamestate.scene_file_path: # Okay so im doing some funky stuff here where I'm seeing if they are the same game state, and if so, checking the already existing one for if they should reload or not.
		#They're the same! We gonna check if they want us to reset or nah
		if active_gamestate.ResetOnReload:
			# Yes we wanna reset!
			server_spawn_gamestate(NewGamestate.resource_path)
		else:
			#Nah we gonna not reset and keep the old one
			pass


# server ONLYYYYYY
func server_spawn_gamestate(gs_path: String):
	if active_gamestate: # If we have an already existing gamestate, queue free dat
		active_gamestate.queue_free() # this is do-able because of the multiplayer spawners automatically queue freeing the old one for clients
	
	# using .spawn() triggers the spawn_function on everyone
	active_gamestate = GameStateSpawner.spawn(gs_path)

func _on_spawner_custom_spawn(path: Variant) -> Node:
	var gs_scene = load(path)
	var instance = gs_scene.instantiate()
	
	# this happens on the client AND the server now. So yippieee
	active_gamestate = instance #make sure we track the new one
	return instance # tell the spawner to keep track of this node for when we delete it later probs
