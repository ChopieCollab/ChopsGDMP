extends Node

@onready var main_root: Node = GameManager.Main_Root ## Technically not the best solution to getting refs but I really dont want to make main_root a global because i don wanna... but I might later.

## Gimmie them signals oooh yeahhhhh.
func _ready() -> void:
	NetworkManager.client_connected.connect(_client_connected)
	NetworkManager.client_disconnected.connect(_client_disconnected)
	GameManager.ChangeMap.connect(_changeMap)

func _client_connected(id: int):
	#I was very tempted to add the default behavior for them spawning in... so I think I might actually do that lmao
	#pass
	if GameManager.active_gamemode.SpawnOnConnect:
		_spawn_player(id, GameManager.active_gamemode.SpawnOnConnectChannel, GameManager.active_gamemode.default_pawn)

func _client_disconnected(id: int): ## Despawn the player. Since this is called on the server, and the players are spawned with a multiplayer spawner, queue freeing it will sync to all clients!
	_despawn_player(id) #The server will be despawning the player since they disconnected.
	#IF YOU WANT TO HAVE SOMETHING BE LEFT BEHIND, GO INTO YOUR PAWN AND HOOK UP A SIGNAL TO THE CLIENT DISCONNECT FROM THE NETWORK MANAGER. THE SERVER OWNS THE PLAYER SO IT WILL RUN.

## Spawn a player. We pass in the ID because we want to set the input prediction to be owned by that ID. c: synced using the multiplayer player spawner. Also only called on server.
func _spawn_player(id: int, spawner_channel: int, pawn_packed: PackedScene):
	await get_tree().process_frame # Wait in case any other scripts modify player spawn locations
	if spawner_channel != 0:
		var spawner_channel_check = spawner_channel
	else:
		spawner_channel = 0
	var player_spawn_locations = get_tree().get_nodes_in_group("PlayerSpawns") # Get all player spawns
	var chosen_spawn = null
	for spawn in player_spawn_locations:
		if !(spawn.SpawnUsed): # Is the spawn used/out of charges?
			if (spawner_channel == spawn.SpawnerChannel): # Is the spawn the one we are looking for with the channel type?
				chosen_spawn = spawn
				break
	var instance = pawn_packed.instantiate()
	if chosen_spawn != null:
		chosen_spawn.usedSpawn()
		instance.global_position = chosen_spawn.global_position
		instance.global_rotation = chosen_spawn.global_rotation
	else:
		push_error("Warning: No player spawns available!")
	instance.name = str(id) #Set the name to be the peer id
	instance.Peer_ID = id #Set the actual peer ID in the pawn for input handling
	self.add_child(instance)
	#GameManager.active_gamemode.default_pawn

## Hopefully only called by the server >->
func _despawn_player(id: int):
	var player_node = self.get_node_or_null(str(id))
	if player_node:
		player_node.queue_free()

func _changeMap(MapPath):
	if GameManager.active_gamemode.RemakePawnsOnMapChange:
		despawnAll()
		var playerIDs = multiplayer.get_peers() # Get all the peer IDs
		for ID in playerIDs:
			_spawn_player(ID, GameManager.active_gamemode.RespawnDefaultChannel, GameManager.active_gamemode.default_pawn)

func _reloadMap(MapPath):
	pass

## Despawn ALLLLL the players... and then HOPEFULLY you're going to respawn them all lol
func despawnAll():
	var playerIDs = multiplayer.get_peers() # Get all the peer IDs
	for ID in playerIDs:
		_despawn_player(ID)
