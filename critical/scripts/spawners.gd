extends Node

@onready var map_spawner: MultiplayerSpawner = $MapSpawner
@onready var player_spawner: MultiplayerSpawner = $PlayerSpawner
@onready var dynamic_spawner: MultiplayerSpawner = $DynamicSpawner
@onready var main_root: Node = GameManager.Main_Root ## Technically not the best solution to getting refs but I really dont want to make main_root a global because i don wanna... but I might later.

## A list of map scenes that are spawned for the players. Only one will be active at a time by default. I opted to put this here instead of a project settings because you can drag and drop maps here.
const map_list: Array[String] = [
	"res://maps/lobbies/MainMenu.tscn"
]

## A list of player scenes that can be spawned for the player. An example would be the spectator camera or a player scene. These are added to the players spawner.
const player_list: Array[String] = [
]

## A list of "items" that are possibly scattered about the level. These are dynamically spawned, since they may be picked up etc. These are added to the dnynamics spawner.
const item_list: Array[String] = [
]

## A list of "dynamics" that are possibly destroyed or might not exist. These are added to the dynamics spawner.
const dynamics_list: Array[String] = [
]

## Defaults to setting the spawners to be everything listed above. The thing is it's *technically* unoptimal... if you want to be a NERD and not save scene refs to memory... depending on how big of a project you might want to use resources for each map and character that add "spawnable items" to the spawners... but regardless, ignore this for now c: 
func _ready() -> void:
	map_spawner.spawn_limit = 1 #Only ONE map at a time. Do not change this. Unless you're doing some funky stuff I guess.
	set_spawn_locations_default()
	clear_spawners()
	populate_spawners_default()

func clear_spawners():
	map_spawner.clear_spawnable_scenes()
	player_spawner.clear_spawnable_scenes()
	dynamic_spawner.clear_spawnable_scenes()

func populate_spawners_default():
	for map in map_list:
		map_spawner.add_spawnable_scene(map)
	for playertype in player_list:
		player_spawner.add_spawnable_scene(playertype)
	for item in item_list:
		dynamic_spawner.add_spawnable_scene(item)
	for dynamic in dynamics_list:
		dynamic_spawner.add_spawnable_scene(dynamic)

func set_spawn_locations_default():
	map_spawner.spawn_path = main_root.world_container.get_path()
	player_spawner.spawn_path = main_root.players.get_path()
	dynamic_spawner.spawn_path = main_root.dynamic_container.get_path()
