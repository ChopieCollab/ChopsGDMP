@tool
extends Node3D

@export_category("Spawn Settings")
@export var LimitUsage: bool = false ## If the spawner can ONLY be used once.
@export var UsageAmount: int = 1 ## How many times the spawner can be used before no more pawns can spawn there.
@export var SpawnerChannel: int = 0: ## Used for spawning people via teams or specific ID references.
	set(value):
		SpawnerChannel = value
		update_preview_label()

var SpawnUsed: bool = false
var UsedAmount: int = 0

func usedSpawn():
	if LimitUsage:
		UsedAmount += 1
		if UsedAmount >= UsageAmount:
			SpawnUsed = true

func resetSpawns():
	UsedAmount = 0
	SpawnUsed = false

## Editor preview stuff
@onready var marker_3d: Marker3D = $Marker3D
const player_start_preview = preload("res://editor assets/preview/PlayerStartPreview.tscn")

func _ready():
	if Engine.is_editor_hint():
		var ps = player_start_preview.instantiate()
		marker_3d.add_child(ps)
		update_preview_label()

func update_preview_label():
	if !Engine.is_editor_hint() or marker_3d == null:
		return
	if marker_3d.get_child_count() > 0:
		var ps = marker_3d.get_node("PlayerStartPreview")
		if ps.is_node_ready():
			var label = ps.get_node("ChannelLabel")
			label.text = str(SpawnerChannel)
			label.visible = (SpawnerChannel != 0)
