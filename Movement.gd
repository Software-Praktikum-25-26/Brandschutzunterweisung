extends CharacterBody3D

# How fast the player moves in meters per second.
@export var speed = 14
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 75
#Jump Power
@export var jump_power = 24

func _physics_process(delta):
	# We create a local variable to store the input direction.
	var direction = Vector3.ZERO

	# We check for each move input and update the direction accordingly.
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		# Notice how we are working with the vector's x and z axes.
		# In 3D, the XZ plane is the ground plane.
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	if Input.is_action_pressed("jump"):
		direction.y -= 10

	direction = transform.basis * direction
	# Ground Velocity
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	# Vertical Velocity
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		velocity.y = velocity.y - (fall_acceleration * delta)

	# Moving the Character
	move_and_slide()
	
@export var mouse_sensitivity := 0.003  # tweak this to taste

var pitch := 0.0  # vertical camera angle

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  # hide and lock cursor

func _unhandled_input(event):
	if event.is_action_pressed("jump"):
		if is_on_floor():
			jump()
	if event is InputEventMouseMotion:
		rotate_player_view(event.relative)
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP and $SpringArm3D.spring_length < 20:
				$SpringArm3D.spring_length += (event.factor if event.factor else 1.0)
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and $SpringArm3D.spring_length >= 0:
				$SpringArm3D.spring_length -= (event.factor if event.factor else 1.0)

func rotate_player_view(mouse_delta: Vector2):
	# Rotate horizontally (yaw)
	rotate_y(-mouse_delta.x * mouse_sensitivity)

	# Rotate vertically (pitch)
	pitch -= mouse_delta.y * mouse_sensitivity
	pitch = clamp(pitch, deg_to_rad(-90), deg_to_rad(45))  # prevent flipping

	$SpringArm3D.rotation.x = pitch
	
func jump():
	velocity.y = jump_power
