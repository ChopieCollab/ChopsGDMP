extends Node

func spawnDynamic(Prop: PackedScene, pos, rot):
	if !multiplayer.is_server():
		return
	
	var prop_instance = Prop.instantiate()
	prop_instance.global_position = pos
	prop_instance.global_rotation = rot
	# Called deffered add prop instance, its not instant because it lowkey dont matter change this if it does for you.
	self.call_deferred("add_child", prop_instance)
