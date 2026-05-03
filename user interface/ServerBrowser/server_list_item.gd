extends Control

var LobbyID: int
var LobbyName: String
var LobbyPing: int
var MainScriptRef = null

@onready var lb_server_name: Label = $HBoxContainer/LB_ServerName
@onready var lb_player_amount: Label = $HBoxContainer/LB_PlayerAmount
@onready var lb_lobby_ping: Label = $HBoxContainer/LB_LobbyPing

func GetMainServerBrowser(ref):
	MainScriptRef = ref

func CalculateData(NewLobbyID: int):
	LobbyID = NewLobbyID
	
	# Lobby Names
	LobbyName = Steam.getLobbyData(LobbyID, "LobbyName")
	if (LobbyName == ""):
		LobbyName = "?????"
		
	# Lobby Ping Calculations, Untested fully but hopefully should work and not cause crashes now.
	var LobbyLocation #= Steam.parsePingLocationString(Steam.getLobbyData(LobbyID, "PingLocation"))
	if (Steam.getLobbyData(LobbyID, "PingLocation") == ""):
		print("No Ping Location Set, Not Calculating Ping")
		lb_lobby_ping.text = "???"
	else:
		LobbyLocation = Steam.parsePingLocationString(Steam.getLobbyData(LobbyID, "PingLocation"))
		LobbyPing = Steam.estimatePingTimeFromLocalHost(LobbyLocation)
		lb_lobby_ping.text = str(LobbyPing)
		
	#print("Here1" + Steam.getLobbyData(LobbyID, "PingLocation"))
	#print("Here!" + LobbyLocation)
	# DO NOT REMOVE OR THIS CAUSES A CRASH BECAUSE IT LEADS TO NULL POINTERS UNDER THE WRAPPER!!!!
	#print(Steam.getRelayNetworkStatus())
	#if (Steam.getRelayNetworkStatus() == 100): #MAKE SURE STEAM RELAY NETWORK IS INITIALIZED
		#print("Yup!")
		#print(Steam.estimatePingTimeFromLocalHost(LobbyLocation))
		#LobbyPing = Steam.estimatePingTimeBetweenTwoLocations(Steam.getLocalPingLocation().get("location"), LobbyLocation)
	
	#LobbyPing = Steam.estimatePingTimeBetweenTwoLocations(Steam.getLocalPingLocation().get("location"), LobbyLocation)
	#LobbyPing = Steam.estimatePingTimeFromLocalHost(LobbyLocation)
	
	lb_server_name.text = LobbyName
	#lb_lobby_ping.text = str(LobbyPing)
	var MaxPlayers: int = Steam.getLobbyMemberLimit(LobbyID)
	var CurrentPlayers: int = Steam.getNumLobbyMembers(LobbyID)
	lb_player_amount.text = (str(CurrentPlayers) + "/" + str(MaxPlayers))
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_bt_join_server_entree_pressed() -> void:
	MainScriptRef.join_lobby(LobbyID)
