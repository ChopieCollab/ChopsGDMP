extends Control

var lobby_id : int = 0
#var peer : SteamMultiplayerPeer
#@export var player_scene : PackedScene
#var is_host : bool = false
#var is_joining : bool = false

signal sb_join(lobby_id_pass)
signal sb_host(privacy, maxplayers, lobbyname)
## NOTICE: IF YOU WANT TO ADD MORE LOBBY TAGS OTHER THAN JUST THE NAME, YOU'LL NEED TO PASS THEM THROUGH HERE.
## AND ALSO MODIFY THE NETWORKMANAGER.

signal sb_join_lan_debug()
signal sb_host_lan_debug()

## HOST
@onready var host_button: Button = $"TabContainer/Host Steam/HBoxContainer/NetworkButtons/HostGameHBox/Host_Button"
@onready var cb_friends_only: CheckBox = $"TabContainer/Host Steam/HBoxContainer/Options/FriendsOnlyVBox/CB_FriendsOnly"
@onready var sb_max_player: SpinBox = $"TabContainer/Host Steam/HBoxContainer/Options/MaxPlayerHBox/SB_MaxPlayer"
@onready var txt_lobby_name: LineEdit = $"TabContainer/Host Steam/HBoxContainer/Options/LobbyNameHBox/TXT_LobbyName"
@onready var cb_use_steam: CheckBox = $"TabContainer/Host Steam/HBoxContainer/NetworkButtons/UseSteamHBox/CB_UseSteam"

## JOIN
@onready var id_prompt: LineEdit = $"TabContainer/Join Steam/HBoxContainer/SearchFilter/DirectConnectVBox/ID Prompt"
@onready var join_button: Button = $"TabContainer/Join Steam/HBoxContainer/SearchFilter/DirectConnectVBox/Join_Button"
@onready var sb_slots_open: SpinBox = $"TabContainer/Join Steam/HBoxContainer/SearchFilter/SlotsOpenVBox/SB_SlotsOpen"
@onready var hs_search_distance: HSlider = $"TabContainer/Join Steam/HBoxContainer/SearchFilter/DistanceVBox/VBoxContainer/HS_SearchDistance"
@onready var server_list_container: VBoxContainer = $"TabContainer/Join Steam/HBoxContainer/Search Results/ScrollContainer/ServerListContainer"
@onready var cb_friends_only_join: CheckBox = $"TabContainer/Join Steam/HBoxContainer/SearchFilter/FriendsOnlyVBox/CB_FriendsOnly"
@onready var cb_hide_full: CheckBox = $"TabContainer/Join Steam/HBoxContainer/SearchFilter/HideFullVBox/CB_HideFull"

## ENet


var ServerListItem = preload("res://user interface/ServerBrowser/server_list_item.tscn")

## DEBUG


func _ready():
	#Steam.lobby_created.connect(_on_lobby_created) # tie steam to the lobby created
	#Steam.lobby_joined.connect(on_lobby_joined) # gets called on EVERY peer regardless on if they are joining or not.
	
	## NOTICE I AM CONNECTING THE UI TO THE NETWORK MANAGER FROM THE UI BECAUSE THE UI IS TRANSIENT WHILE THE NETWORK MANAGER IS A GLOBAL.
	## YOU CAN ADD DIFFERENT THINGS THAT LET YOU JOIN LOBBIES, OR LEAVE THEM ETC IN THE GAME, BUT THEY SHOULD CONNECT TO THE NETWORK MANAGER.
	sb_host.connect(NetworkManager.host_lobby)
	sb_join.connect(NetworkManager.join_lobby)
	sb_host_lan_debug.connect(NetworkManager.HostLanDebug)
	sb_join_lan_debug.connect(NetworkManager.JoinLanDebug)
	
	
func host_lobby():
	#print("Test!")
	var PRIVACY
	var MAXPLAYERS = sb_max_player.value
	if cb_friends_only.is_pressed():
		PRIVACY = Steam.LobbyType.LOBBY_TYPE_FRIENDS_ONLY #Friends can join freely and be invited, doesnt show up on server list
		print("Friends Only Lobby")
	else:
		print("Public Lobby")
		PRIVACY = Steam.LobbyType.LOBBY_TYPE_PUBLIC #Visible to friends, returned by search
	
	
	sb_host.emit(PRIVACY, MAXPLAYERS, txt_lobby_name.text)
	#Steam.createLobby(PRIVACY, MAXPLAYERS)
	#is_host = true

func join_lobby(lobby_id : int):
	print("Joining Lobby ID: " + str(lobby_id))
	sb_join.emit(lobby_id)
	#is_joining = true
	#Steam.joinLobby(lobby_id)
	
func on_lobby_joined(lobby_id : int, permissions : int, locked : bool, response : int):
	pass


func SearchLobbies(ClearList: bool):
	#Possibly add a function here to apply the fliters beforehand
	applyFilters()
	
	if ClearList: # If set to clear the server list (refreshing fully) then clear it.
		for child in server_list_container.get_children():
			child.queue_free()
	
	#This calls the requestlobbylist
	Steam.requestLobbyList()
	Steam.lobby_match_list.connect(requestedLobbies)
	
	#Steam.addRequestLobbyListFilterSlotsAvailable(0) #For ALL games. By default it hides full lobbies.
	return

func applyFilters():
	#print(sb_slots_open.value)
	Steam.addRequestLobbyListFilterSlotsAvailable(sb_slots_open.value) #For ALL games. By default it hides full lobbies. 0 is all games.
	Steam.addRequestLobbyListDistanceFilter(hs_search_distance.value) #0 is immediate region, 1 is same region or nearby, 2 is half way around the globe, 3 is NO filtering by distance.

func requestedLobbies(lobbies): #Might be able to use IOFailure to determine if a failure occurred... but not going to for now cause not in docs for gdscript
	for LobbyID in lobbies:
		
		if (cb_friends_only_join.button_pressed): #if we filtering to friends only
			var OwnerID = Steam.getLobbyOwner(LobbyID)
			if (Steam.getFriendRelationship(OwnerID) != 3): # check if friends
				continue #skip if we aint friends
		
		if (cb_hide_full.button_pressed): #See if we only want non full lobbies
			var MaxPlayers: int = Steam.getLobbyMemberLimit(LobbyID)
			var CurrentPlayers: int = Steam.getNumLobbyMembers(LobbyID)
			if (CurrentPlayers >= MaxPlayers):
				continue # skipppp
		
		var LobbyEntree = ServerListItem.instantiate()
		server_list_container.add_child(LobbyEntree)
		LobbyEntree.CalculateData(LobbyID)
		LobbyEntree.GetMainServerBrowser(self)
		Steam.getRelayNetworkStatus()
		#await get_tree().create_timer(5.0).timeout
		#server_list_container.add_child(LobbyEntree)
		#var JoinButton = LobbyEntree.get_node("BT_JoinServerEntree")
		#JoinButton.connect("pressed", self, "_on_join_button_lobby_pressed", LobbyID)
		print("Lobby ID: ", LobbyID)
	return

func _on_lobby_created(result: int, lobby_id: int):
	#print("Check2")
	if result == Steam.Result.RESULT_OK:
		#print("Check1")
		id_prompt.text = str(lobby_id)
		#print("Lobby created, lobby ID: ", lobby_id)


func _on_host_button_pressed() -> void:
	print("Test")
	host_lobby()


func _on_id_prompt_text_changed(new_text: String) -> void:
	join_button.disabled = (new_text.length() == 0)


func _on_join_button_pressed() -> void:
	if id_prompt.text.to_int():
		join_lobby(id_prompt.text.to_int())
		


func _on_btn_refresh_pressed() -> void:
	SearchLobbies(true)
	pass # Replace with function body.


func _on_btn_host_debug_pressed() -> void:
	sb_host_lan_debug.emit()
	pass # Replace with function body.


func _on_btn_join_debug_pressed() -> void:
	sb_join_lan_debug.emit()
	pass # Replace with function body.
