@tool
extends Marker3D

@export var prop_scene: PackedScene:
	set(value):
		prop_scene = value
		if Engine.is_editor_hint():
			_update_preview()

var _preview_node: Node = null

func _ready():
	if Engine.is_editor_hint(): #only do this stuff in the editor c:
		_update_preview()
		return
	if multiplayer.is_server(): # ONLY THE SERVER SHOULD EVER EVER EVER EVER SPAWN THINGS UNLESS THE THINGS BEING SPAWNED ARE CLIENT SIDE.
		GameManager.Main_Root.dynamic_container.spawnDynamic(prop_scene, global_position, global_rotation)
	queue_free()


func _update_preview():
	if is_instance_valid(_preview_node):
		_preview_node.queue_free()
		_preview_node = null
		
	if prop_scene:
		_preview_node = prop_scene.instantiate()
		add_child(_preview_node)
