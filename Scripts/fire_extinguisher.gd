extends Node3D

@onready var particles = $GPUParticles3D
@onready var raycast = $RayCast3D

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse_button"):
		set_spraying(true)
	elif event.is_action_released("left_mouse_button"):
		set_spraying(false)

func _physics_process(delta: float) -> void:
	if raycast.enabled and raycast.is_colliding():
		_process_hit(raycast.get_collider())

func set_spraying(enabled: bool) -> void:
	particles.emitting = enabled
	raycast.enabled = enabled

func _process_hit(hit_obj: Object) -> void:
	if not hit_obj or not is_instance_valid(hit_obj):
		return
	
	var parent = hit_obj.get_parent()
	if parent and parent.has_method("extinguish"):
		parent.extinguish(hit_obj)
