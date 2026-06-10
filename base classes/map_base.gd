class_name MapBase3D
extends Node3D

@export_category("Map Settings")
@export var map_name: String = "Forgor To Name"
@export var default_gamemode: PackedScene:
	set(value):
		default_gamemode = value
		_validate_scene()

func _ready() -> void:
	if !default_gamemode:
		push_error("ERROR: No gamemode, or invalid, selected for map!")
	else:
		GameManager.gamemode_packed = default_gamemode
	if map_name == "Forgor To Name":
		push_error("Warning: Forgot to name map!")

func _validate_scene():
	if Engine.is_editor_hint():
		if default_gamemode != null:
			var test_instance = default_gamemode.instantiate()
			if !(test_instance is GamemodeBase):
				push_error("Error: Use a GamemodeBase!")
				# Reset because nuhuh you better use a gamemode or else
				default_gamemode = null 
			test_instance.free()
