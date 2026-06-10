extends Node

## --- NODE REFS ----------------------------------
@onready var ui_container: Node = $UIContainer
@onready var world_container: Node = $WorldContainer
@onready var dynamic_container: Node = $DynamicContainer
@onready var players: Node = $Players
@onready var spawners: Node = $Spawners

@export var StartupMap: PackedScene #MapBase3D
@export var StartupUI: PackedScene ## You dont necessarily have to do it here. But for convenience of testing if you want you can drag in your starting
# I would actually advise against using a startupUI, and instead handle all that in the map or the pawn of the player when starting it
# Like if you're doing a main menu, have the player handle the starting UI but technically you do you gang

func _enter_tree():
	# its THEEEEE main root.
	GameManager.Main_Root = self

func _ready() -> void:
	if StartupMap != null:
		GameManager.changeMap(StartupMap.resource_path)
	if StartupUI != null:
		ui_container.open_ui(StartupUI)
	
	## Apparently, children call their ready functions first, and since spawners looks at the variables inside here to init, so call your readies here.
	spawners.spawner_ready()
