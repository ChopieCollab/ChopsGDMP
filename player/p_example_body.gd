extends Pawn


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@onready var input: Node = $Input

## HOW YOU DO NETCODE MOVEMENT/BASIC TUTORIAL
func _rollback_tick(delta, tick, is_fresh):
	velocity = input.movement.normalized() * SPEED
	
	_force_update_is_on_floor()
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if input.movement.y != 0 and is_on_floor():
		velocity.y = input.movement.y * JUMP_VELOCITY
	
	velocity *= NetworkTime.physics_factor
	move_and_slide()
	velocity /= NetworkTime.physics_factor

## NOTICE: This is done because of a technical limitation with Godot/Netfox.
## Character bodies only update their is_on_floor state AFTER a move and slide call, meaning that
## we need to FORCE it to update for rollback to be properly working. [If we didn't do this,
## during the rollback, the position would be updated but the is_on_floor state wouldn't.
func _force_update_is_on_floor():
	var old_velocity = velocity
	velocity = Vector3.ZERO
	move_and_slide()
	velocity = old_velocity


## DEFAULT CODE
#func _physics_process(delta: float) -> void:
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#if direction:
		#velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)
#
	#move_and_slide()
