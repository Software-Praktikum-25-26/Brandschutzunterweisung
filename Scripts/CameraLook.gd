extends SpringArm3D

@export var mouse_sensitivity := 0.003  # tweak this to taste

var player

func _ready():
	player = get_parent()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  # hide and lock cursor
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_player_view(event.relative)
		if event is InputEventMouseButton:
			if event.is_pressed():
				if event.button_index == MOUSE_BUTTON_WHEEL_UP and spring_length < 20:
					spring_length += (event.factor if event.factor else 1.0)
				if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and spring_length > 0:
					spring_length -= (event.factor if event.factor else 1.0)

func rotate_player_view(mouse_delta: Vector2):
	player.rotate_y(-mouse_delta.x * mouse_sensitivity)
	rotate_x(-mouse_delta.y * mouse_sensitivity)
	rotation.x = clamp(rotation.x, deg_to_rad(-90), deg_to_rad(45))
