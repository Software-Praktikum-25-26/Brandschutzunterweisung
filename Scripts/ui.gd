extends Control

# Use a generic path or export it so it doesn't break when moving nodes
@export var player_path: NodePath = "../../Player" 
@onready var player = get_node_or_null(player_path)

func _ready():
	# VERY IMPORTANT: This allows the UI to work even if you pause the game
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	self.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"): # Escape Key
		if self.visible:
			_on_resume_btn_pressed()
		else:
			_open_menu()

func _open_menu():
	self.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	# 1. Force the mouse back into the game window
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# 2. Force the game to unpause (just in case it was paused)
	get_tree().paused = false

	# 3. Explicitly tell the player to start moving
	if player and player.has_method("_start_moving"):
		player._start_moving()
	else:
		# Debugging: if this prints, the path to your player is wrong!
		print("UI Error: Cannot find player or _start_moving method!")
	# If you want the fire/game to stop while menu is open:
	# get_tree().paused = true 

func _on_resume_btn_pressed():
	self.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# get_tree().paused = false
	if player and player.has_method("_start_moving"):
		player._start_moving()

func _on_exit_btn_pressed():
	get_tree().quit()
