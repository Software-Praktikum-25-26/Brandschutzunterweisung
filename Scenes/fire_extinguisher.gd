extends Node3D



func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse_button"):
		$GPUParticles3D.emitting = true
	if event.is_action_released("left_mouse_button"):
		$GPUParticles3D.emitting = false
