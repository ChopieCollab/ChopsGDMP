extends Node

## --- NODE REFS ----------------------------------
@onready var ui_container: Node = $UIContainer
@onready var world_container: Node = $WorldContainer
@onready var dynamic_container: Node = $DynamicContainer
@onready var players: Node = $Players
@onready var spawners: Node = $Spawners

@export var StartupMap: MapBase3D
@export var StartupUI: CanvasLayer ## You dont necessarily have to do it here. But for convenience of testing if you want you can drag in your starting
# I would actually advise against 
func _enter_tree():
	# its THEEEEE main root.
	GameManager.Main_Root = self

func _ready() -> void:
	
