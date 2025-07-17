extends CharacterBody3D

# How fast the player moves in meters per second.
@export var speed = 14
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 75
@export var jump_power = 24

@onready var timer: Timer = $Timer
@onready var menu: Control = $"../menu"
@onready var health_bar: Label = $Control/HealthBar
@export var damage_flash: ColorRect

var hp = 100

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

	# This part for jump direction is not standard, but keeping it as is.
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

func _unhandled_input(event):
	if event.is_action_pressed("jump"):
		if is_on_floor():
			jump()
			
func _ready() -> void:
	_set_health_bar()

# Handling player input
func _input(event) -> void:
	# checking what type of input we want to check,
	# checking if key is pressed
	# checking what key is pressed
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_ESCAPE:
		_stop_moving()
		_show_menu()
	
	
func jump():
	velocity.y = jump_power

func _show_menu():
	menu.show()
	
func _stop_moving():
	set_physics_process(false)
func _start_moving():
	set_physics_process(true)
	
func _set_health_bar():
	health_bar.text = "Your Health is: " + str(hp)

func _fire_damage():
	hp = hp -25
	
	# ADD THIS LINE: Call the damage effect function
	_play_damage_effect()

	if hp <= 0:
		print("you are dead, sir. ")
		health_bar.text = "Your Health is: " + str(hp)
		_respawn()
	else:
		health_bar.text = "Your Health is: " + str(hp)

func _respawn():
	# wating for 1 sec
	timer.start(1)
	await timer.timeout
	# reload the main scene
	get_tree().reload_current_scene()

# ADD THIS ENTIRE FUNCTION: This creates the red flash animation
func _play_damage_effect():
	# First, check if the damage_flash node has been assigned in the editor
	if damage_flash:
		damage_flash.visible = true
		var start_color = Color(1, 0, 0, 0.3) 
		var end_color = Color(1, 0, 0, 0)   
		damage_flash.modulate = start_color
		
		# Create a new tween directly in the code
		var tween = create_tween()
		
		# Tell the tween to animate the 'modulate' property to fade out
		tween.tween_property(damage_flash, "modulate", end_color, 0.4)
	else:
		# DEBUG STEP 3: If this message appears, the node is not linked in the Inspector.
		print("ERROR: DamageFlash node not assigned in the Player script's Inspector!")
