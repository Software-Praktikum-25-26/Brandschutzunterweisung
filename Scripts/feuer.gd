extends Node3D

@export var hp = 100
@export var spread_radius: float = 5.0

@onready var fire_fx = $Feuer_Effekt
@onready var smoke_fx = $Feuer_Effekt/Rauch_Effekt
@onready var player: CharacterBody3D = $"../Player"
@onready var spread_timer: Timer = $SpreadTimer


func _ready():
	fire_fx.process_material = fire_fx.process_material.duplicate()
	spread_timer.start()

func extinguish(teil: Object):
	spread_timer.start()
	
	if teil.name == "Basis":
		hp -= 1.0
	elif teil.name == "Rest":
		hp -= 0.2
	
	if hp <= 1:
		ScoreManager.increase_score(500)
		queue_free()
		return

	fire_fx.amount_ratio = hp/100
	fire_fx.lifetime = 0.75 * hp /100
	fire_fx.process_material.scale_max = hp/100
	fire_fx.process_material.initial_velocity_max = 5*hp/100
	smoke_fx.position.y -= 0.01


func _on_basis_body_entered(body3D) -> void:
	if body3D is CharacterBody3D:
		player._fire_damage()


func _on_spread_timer_timeout() -> void:
	#check if this node is saved as a scene and loads it by its path.
	if self.scene_file_path.is_empty():
		push_error("Cannot spread fire because the source fire is not a saved scene.")
		return

	# Load the scene resource from its own path.
	var fire_scene_resource = load(self.scene_file_path)
	
	var random_direction = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	var random_distance = randf_range(1.0, spread_radius)
	var new_position = self.global_position + random_direction * random_distance
	
	var new_fire = fire_scene_resource.instantiate()
	get_parent().add_child(new_fire)
	new_fire.global_position = new_position

	spread_timer.start()
