extends CharacterBody3D

@export var speed = 14
@export var fall_acceleration = 75
@export var jump_power = 24
@export var damage_flash: ColorRect

@onready var timer: Timer = $Timer
@onready var menu: Control = $"../menu"
@onready var health_bar: Label = $Control/HealthBar
var hp = 100

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_update_health_bar()

func _physics_process(delta):
	# Handle gravity
	if not is_on_floor():
		velocity.y -= fall_acceleration * delta

	# Get input for movement
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Apply movement
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	# Handle jumping
	if event.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_power
	
	# Handle pausing
	if event.is_action_pressed("ui_cancel"):
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		menu.show()
	
func _update_health_bar():
	health_bar.text = "Your Health is: " + str(hp)

func _damage(damage: int):
	hp -= damage
	_play_damage_effect()

	if hp <= 0:
		hp = 0
		print("you are dead, sir. ")
		_respawn()
	
	_update_health_bar()

func _respawn():
	timer.start(1)
	await timer.timeout
	get_tree().reload_current_scene()

func _play_damage_effect():
	if not damage_flash:
		return

	damage_flash.visible = true
	damage_flash.modulate = Color(1, 0, 0, 0.4)
	var tween = create_tween()
	tween.tween_property(damage_flash, "modulate", Color(1, 0, 0, 0), 1.0)
