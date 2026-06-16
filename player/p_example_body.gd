extends Pawn


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@onready var input: Node = $Input
@onready var head: Node3D = $Head
@onready var camera_3d: Camera3D = $Head/Camera3D
@onready var client_hidden: Node3D = $ClientHidden
@onready var client_drawn_over: Node3D = $ClientDrawnOver
@onready var glasses: MeshInstance3D = $Head/Glasses


func _ready() -> void:
	## NOTICE \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
	super() ## NOTICE YOU BETTER DO THIS OR ELSE I WILL FIND YOU.
	## NOTICE ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	#print("Spawned!")
	
	if Peer_ID == multiplayer.get_unique_id(): #Checking the current instance of multiplayer against the "owner"
		## NOTICE: You will likely be doing this unless you handle this code on the Input node, because
		## The server is technically the multiplayer authority on this node, we can't do multiplayer.is_authority().
		## Hence, we have the peer_id set and we compare that instead.
		camera_3d.make_current() # set the camera to be used by the player who is controlling this pawn.
		camera_3d.top_level = true # Doing this so we can have camera movement be uncapped FPS on the client but also have synced
		# Head movement across the network :>
		
		## NOTICE: I am setting the layer mask for these items on the OWNING CLIENT.
		## Other clients will have them all on layer 1 still. Or whatever their default is.
		## I am stealing this from Arson :> Also 9 is going to be the mask for "client no see this" and 16 for "client render this
		## overtop of geometry
		glasses.layers = 1 << 8 #Sets to 9 to hide the glasses, just in case.
		set_layer_recursively(client_hidden, 1 << 8) # sets to 9
		set_layer_recursively(client_drawn_over, 1 << 15) #Client side rendering over other objects sets to 16
		## NOTICE: This is unused and heavily depends on how you setup the character.
		## I'd look at GDCShoot and look at Arson and how it's handled there.
		## You can have a True First Person in which case you might not want to have a render layer for hand models
		## Or you can do first person where you have a specific hand model set that gets rendered by the player.
		## OR you may just not have a true first person anyway so you really dont care, this is just an example :>


## HOW YOU DO NETCODE MOVEMENT/BASIC TUTORIAL
func _rollback_tick(delta, tick, is_fresh):
	
	rotation.y = input.look_rotation.x 
	head.rotation.x = input.look_rotation.y # Notice this happens to every client, even the owner, but that the owning client
	# has their head as top level.
	
	_force_update_is_on_floor() # see notice below
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if input.movement.y > 0 and is_on_floor():
		velocity.y = input.movement.y * JUMP_VELOCITY #Jump is gathered from movement y :>
	
	var aim_basis = Basis.from_euler(Vector3(0, input.look_rotation.x, 0)) #Use the inputs look angle to calculate WSAD movement
	var direction = (aim_basis * Vector3(input.movement.x, 0, input.movement.z)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = 0
		velocity.z = 0
	
	velocity *= NetworkTime.physics_factor #Look at netfox limitations documentation to see why you do this.
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


## NOTICE: Code I stole shamelessly from myself :> ARSON MY BELOVED
func set_layer_recursively(node: Node, layer_number: int):
	if "layers" in node:
		node.layers = layer_number
	for child in node.get_children():
		set_layer_recursively(child, layer_number)
