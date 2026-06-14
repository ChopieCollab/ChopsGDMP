extends Node

var movement = Vector3.ZERO
var look_rotation = Vector2.ZERO
## I did use AI for implementing the controller look rotation because I haven't done that before in Godot.
var _mouse_delta = Vector2.ZERO
var absolute_yaw = 0.0
var absolute_pitch = 0.0
var mouse_sensitivity = 0.002
var gamepad_sensitivity = 2.5

func _ready():
	NetworkTime.before_tick_loop.connect(_gather)
	
	await get_tree().process_frame # Waiting for the Peer_ID to be updated
	await get_tree().process_frame
	if is_multiplayer_authority():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if !is_multiplayer_authority():
		return
	
	# Apply mouse motion directly to absolute angles
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		absolute_yaw -= event.relative.x * mouse_sensitivity
		absolute_pitch -= event.relative.y * mouse_sensitivity
		
		# Clamp pitch here so it never goes past straight up/down
		absolute_pitch = clamp(absolute_pitch, deg_to_rad(-89), deg_to_rad(89))


func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
		
	var gamepad_look = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	if gamepad_look.length() > 0:
		absolute_yaw -= gamepad_look.x * gamepad_sensitivity * delta
		absolute_pitch -= gamepad_look.y * gamepad_sensitivity * delta
		absolute_pitch = clamp(absolute_pitch, deg_to_rad(-89), deg_to_rad(89))
	
	# The camera is DECOUPLED so it doesnt move at 60Hz.
	var pawn = get_parent()
	# The camera is pinned to the head position, since it's top level we need to do this.
	pawn.camera_3d.global_position = pawn.head.global_position
	# but the camera also lets you apply your mouse input at whatever your FPS is!
	pawn.camera_3d.rotation.y = absolute_yaw
	pawn.camera_3d.rotation.x = absolute_pitch

func _gather():
	if not is_multiplayer_authority():
		return
	
	movement = Vector3(
		Input.get_axis("move_west", "move_east"),
		Input.get_action_strength("move_jump"),
		Input.get_axis("move_north", "move_south")
	) ## WSAD movement AND jumping in one vector :>
	
	look_rotation = Vector2(absolute_yaw, absolute_pitch)
