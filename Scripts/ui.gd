extends Control
@onready var ui: Control = $"."
@onready var player: CharacterBody3D = $"../Player"


func _on_exit_btn_pressed() -> void:
	# to quit and close the game
	get_tree().quit()


func _on_resume_btn_pressed() -> void:
	ui.hide()
	player._start_moving()
