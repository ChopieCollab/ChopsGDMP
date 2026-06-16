@tool
class_name Pawn
extends CharacterBody3D

#@export_category("Debugging Tools")
#@export var debug_mode : bool = false
#@export var DebugMapOverride: PackedScene
#var DebugMapOverridePath = "Null"

## Put base pawn stuff for your game here!
## Or extend this class further, I'm not your mom.
@export_category("Pawn Requirements")
@export var RollbackSync: RollbackSynchronizer
@export var InputNode: Node


var Peer_ID: int

func _ready() -> void: ## NOTICE: YOU BETTER USE SUPER() IN YOUR READY FUNCS YOU GOOBERS
	
	#if debug_mode and OS.has_feature("editor") and get_tree().current_scene == self:
		#debugmode()
		#return
	
	# Wait a frame just in case, so peer_id is set by spawner
	## I'm adding a delay here because the order of operations for setting the owner is SLIGHTLY off.
	## I recommend fixing this if you want but I personally cannot be bothered rn
	#await get_tree().process_frame # Waiting for the Peer_ID to be updated
	await get_tree().process_frame
	Peer_ID = name.to_int()
	set_multiplayer_authority(1, true) # Server owns the entire thing, BUT
	InputNode.set_multiplayer_authority(Peer_ID) # the client owns the input node :>
	RollbackSync.process_settings() # Must be called for the rollback system to be synchronized. :>
	
	#if debug_mode:
		## 1. Create a dummy server so RPCs and Authority work locally
		#var peer = ENetMultiplayerPeer.new()
		#peer.create_server(9999) # Arbitrary port
		#multiplayer.multiplayer_peer = peer
		#
		## Force name to 1 (Server ID) so label and damage logic work
		#name = "1"
		#set_multiplayer_authority(1)
		#
		#var debug_environment : = TEST_ENVIRONMENT.instantiate()
		#add_child(debug_environment)
		#debug_environment.top_level = true
		#
		#print("--- DEBUG MODE ACTIVE: Local Server & Floor Generated ---")
	


#func isnt_on_main_scene() -> bool:
	#var default_main_scene = ProjectSettings.get_setting("application/run/main_scene")
	#var active_scene = get_tree().current_scene.scene_file_path
	#return default_main_scene != active_scene

#func debugmode():
	#if OS.has_feature("editor"):  #and isnt_on_main_scene():
		#if DebugMapOverride != null:
			#DebugMapOverridePath = DebugMapOverride.resource_path
		#GameManager.TriggerDebugBoot(self.scene_file_path, DebugMapOverridePath)
		#
		#print("TEST SUCCESS!")
