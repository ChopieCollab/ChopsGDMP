extends Node
## MEAT AND POTATOES OF ACTUALLY HAVING A MULTIPLAYER GAME! FOR FWEE?! C:
## Courtesy of my Trenchrun refactor and a few tweaks btw ;>

#I'm standardizing this, but you cant really do export vars for global/autoloads tmk so like lmao
#If you use the netcoded debug funcs, this will turn them all off or on
@export var enable_dev_debugging: bool = true

var lobby_id : int = 0
var peer : SteamMultiplayerPeer
var debugpeer : ENetMultiplayerPeer
var debugport : int = 7000
var is_host : bool = false
var is_joining : bool = false
var lobby_name : String = ""

### Get GUI manager
#@onready var gui_mgr: Node = $"../GuiMgr"
#@onready var players_mgr: Node = $"../PlayersMgr"
#@onready var level_mgr: Node = $"../LevelMgr"
#@onready var server: Node = $Server
#@onready var client: Node = $Client
#@onready var bullets_mgr: Node = $"../BulletsMgr"
#
var master_seed: int = 0
#var client_seed: int = 0
#@onready var rng = RandomNumberGenerator.new()

#signal network_lobby_joined

signal connection_successful ## Called on Lobby Joined
signal connection_failed ## Unused for now
signal lobby_id_ready(id: int) ## On lobby created

signal client_disconnected(id: int) ## When a client leaves the server
signal client_connected(id: int)

func _init():
	var init_response: bool = Steam.steamInit(480, true)
	debug("Steam initialized: " + str(init_response))
	Steam.initRelayNetworkAccess()
	Steam.initAuthentication()

func _ready():
	#
	#gui_mgr.gui_host_game.connect(host_lobby)
	#gui_mgr.gui_join_game.connect(join_lobby)
	#gui_mgr.gui_host_game_lan_debug.connect(HostLanDebug)
	#gui_mgr.gui_join_game_lan_debug.connect(JoinLanDebug)
	
	#Dont need to init steam since it's init in project config settings NVM WE DO HAVE TO TO GET CALLBACKS LOL THANKS DOCUMENTATION FOR NOTHING!
	#print("Steam initialized: ", Steam.steamInit(480, true))
	#Steam.initRelayNetworkAccess()
	#Steam.initAuthentication()
	Steam.lobby_created.connect(_on_lobby_created) # tie steam to the lobby created
	Steam.lobby_joined.connect(on_lobby_joined) # gets called on EVERY peer regardless on if they are joining or not.
	
	#Testing Achievements
	#Steam.requestUserStats(Steam.getSteamID())
	#Steam.setAchievement("ACH_WIN_100_GAMES")
	#Steam.storeStats()
	
func host_lobby(privacy, maxplayers, servername):
	Steam.createLobby(privacy, maxplayers)
	lobby_name = servername
	is_host = true

func join_lobby(lobby_id : int):
	#print("Joining Lobby ID: " + str(lobby_id))
	is_joining = true
	Steam.joinLobby(lobby_id)

func on_lobby_joined(lobby_id : int, permissions : int, locked : bool, response : int):
	if !is_joining:
		return #Only call the below code if you are joining as a client
	
	self.lobby_id = lobby_id #set our lobby ID to the one we join
	peer = SteamMultiplayerPeer.new()
	peer.server_relay = true
	peer.create_client(Steam.getLobbyOwner(lobby_id))
	multiplayer.multiplayer_peer = peer
	
	multiplayer.peer_disconnected.connect(_peer_disconnected) ## CLIENT SIDE ONLY, WHEN THE CLIENT DISCONNECTS.
	#gui_mgr.HideServerBrowser()
	
	NetworkTime.start()
	
	#connection_successful.emit()
	is_joining = false
	

func InitLobbyData():
	if is_host: #just in case
		Steam.setLobbyData(lobby_id, "LobbyName", lobby_name); # LOBBY NAME
		
		# This might be buggy because steam hasn't had time to init the network fully? Might need to wait/redo it later, but we shall see.
		var HostLocationString: String = Steam.convertPingLocationToString(Steam.getLocalPingLocation().get("location")) # Get the host's steam network location for ping calculations...
		Steam.setLobbyData(lobby_id, "PingLocation", HostLocationString) # Set the steam location
		#Steam.setLobbyData(lobby_id,)
	return

func _on_lobby_created(result: int, lobby_id: int):
	#print("Check2")
	if result == Steam.Result.RESULT_OK:
		#print("Check1")
		self.lobby_id = lobby_id
		
		peer = SteamMultiplayerPeer.new()
		peer.server_relay = true
		peer.create_host()
		
		if multiplayer.is_server():
			randomize()
			master_seed = randi()
			debug("Master Seed is: " + str(master_seed))
			#_init_local_rng(master_seed, multiplayer.get_unique_id())
		
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_connected.connect(_peer_connected) # NEW: Call a func in the server network manager and emit signal, OLD: Add a player when someone connects
		multiplayer.peer_disconnected.connect(_peer_disconnected) # Call a function and emit when a peer disconnects.
		multiplayer.peer_connected.connect(_sync_player_rng) #Sync the master seed
		#multiplayer.peer_disconnected.connect(players_mgr._remove_player) # Remove a player when someone disconnects
		#level_mgr.change_level("res://Multiplayer/LEVELS/MainHub.tscn") # Change the level to the basic hub
		#players_mgr._add_player(peer.get_unique_id()) # Add a player for ourselves since we're hosting.
		client_connected.emit(peer.get_unique_id()) # So we add ourselves.
		
		NetworkTime.start()
		
		#connection_successful.emit()
		lobby_id_ready.emit(lobby_id)
		
		InitLobbyData() # Setting the lobby data for server browser
		#gui_mgr.HideServerBrowser()
		debug("Lobby created, lobby ID: " + str(lobby_id))



## DEBUG LAN HOSTING
func HostLanDebug():
	debugpeer = ENetMultiplayerPeer.new()
	var error = debugpeer.create_server(debugport, 4)
	if error == OK:
		multiplayer.multiplayer_peer = debugpeer
		multiplayer.peer_connected.connect(_peer_connected) # NEW: Call a func in the server network manager and emit signal, OLD: Add a player when someone connects
		multiplayer.peer_disconnected.connect(_peer_disconnected) # Call a function and emit when a peer disconnects.
		multiplayer.peer_connected.connect(_sync_player_rng) #Sync the master seed
		#multiplayer.peer_connected.connect(_sync_player_rng)
		debug("LAN server hosted!")
		NetworkTime.start()
		
		if multiplayer.is_server():
			randomize()
			master_seed = randi()
			debug("Master Seed is: " + str(master_seed))
			#_init_local_rng(master_seed, multiplayer.get_unique_id())
		
		#gui_mgr.HideServerBrowser()
		#multiplayer.peer_connected.connect(players_mgr._add_player) # Add a player when someone connects
		#multiplayer.peer_disconnected.connect(players_mgr._remove_player) # Remove a player when someone disconnects
		#level_mgr.change_level("res://Multiplayer/LEVELS/MainHub.tscn") # Change the level to the basic hub
		#players_mgr._add_player(debugpeer.get_unique_id()) # Add a player for ourselves since we're hosting.

func JoinLanDebug():
	debugpeer = ENetMultiplayerPeer.new()
	var error = debugpeer.create_client("127.0.0.1", debugport)
	if error == OK:
		#gui_mgr.HideServerBrowser()
		multiplayer.multiplayer_peer = debugpeer
		debug("Joined LAN server!")
		multiplayer.peer_disconnected.connect(_peer_disconnected)
		NetworkTime.start()
	pass

func _peer_connected(id: int):
	connection_successful.emit()
	client_connected.emit(id)

func _peer_disconnected(id: int):
	client_disconnected.emit(id)

## Runs on SERVER: Triggered when a new player connects to sync the master seed
func _sync_player_rng(id: int):
	# Only the server sends the master seed
	debug("Syncing Player RNG!")
	if multiplayer.is_server():
		# We send the Master Seed; we are going to use this to add a modifier to random values that are synced on netfox later
		receive_rng_setup.rpc_id(id, master_seed)
		
## Runs on CLIENT: Receives the master seed from server
@rpc("authority", "call_remote", "reliable")
func receive_rng_setup(server_master_seed: int):
	master_seed = server_master_seed
	#var my_id = multiplayer.get_unique_id()
	#_init_local_rng(master_seed, my_id)

### DEPRECATED HEHEHEHA
#func _init_local_rng(m_seed: int, p_id: int):
	#pass
	# This creates a seed unique to THIS player but known by the server
	# We use hash() to ensure the seed is well-mixed
	#rng.seed = hash(str(m_seed) + str(p_id))
	#print("RNG Initialized for Player ", p_id, " with unique seed.") 


#region Debugger Print Helpers
## I made these so debugging netcode stuff will be easier C:
#region alt name funcs
func dbg(PrintMessage):
	debug(PrintMessage)
func gdbg(PrintMessage, id: int):
	globaldebug(PrintMessage, id)
func sdbg(PrintMessage):
	serverdebug(PrintMessage)
#endregion

func debug(PrintMessage):
	if enable_dev_debugging:
		if OS.is_debug_build():
			print(str(multiplayer.get_unique_id()) + " | " + str(PrintMessage))
	
func globaldebug(PrintMessage, id: int):
	if enable_dev_debugging:
		if OS.is_debug_build():
			RPCAllDebug.rpc(PrintMessage, id)

func serverdebug(PrintMessage):
	if enable_dev_debugging:
		if OS.is_debug_build():
			if !multiplayer.is_server():
				RPCServerDebug.rpc_id(1, PrintMessage)
			else:
				debug(PrintMessage)

@rpc("any_peer", "call_local", "unreliable_ordered", 3)
func RPCAllDebug(PrintMessage, id: int):
	print(str(id) + " | " + str(PrintMessage))

@rpc("any_peer", "call_local", "unreliable_ordered", 3)
func RPCServerDebug(PrintMessage):
	print(str(multiplayer.get_remote_sender_id()) + " | " + str(PrintMessage))

#endregion
