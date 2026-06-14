@tool
class_name Pawn
extends CharacterBody3D

## Put base pawn stuff for your game here!
## Or extend this class further, I'm not your mom.
@export_category("Pawn Requirements")
@export var RollbackSync: RollbackSynchronizer
@export var InputNode: Node


var Peer_ID: int

func _ready() -> void: ## NOTICE: YOU BETTER USE SUPER() IN YOUR READY FUNCS YOU GOOBERS
	# Wait a frame just in case, so peer_id is set by spawner
	await get_tree().process_frame
	Peer_ID = name.to_int()
	set_multiplayer_authority(1, true) # Server owns the entire thing, BUT
	InputNode.set_multiplayer_authority(Peer_ID) # the client owns the input node :>
	RollbackSync.process_settings() # Must be called for the rollback system to be synchronized. :>
