extends Node3D


@export var hp = 100
@export var spread_radius: float = 7.0
@onready var fire_fx = $Feuer_Effekt
@onready var smoke_fx = $Feuer_Effekt/Rauch_Effekt
@onready var player: CharacterBody3D = $"../Player"
@onready var spread_timer: Timer = $Spread_Timer
var fire_damage = 10


func _ready():
	# Duplicate the shared material so it's unique to this instance
	fire_fx.process_material = fire_fx.process_material.duplicate()
	spread_timer.start()

func extinguish(teil: Object):
	spread_timer.start()
	
	if teil.name == "Basis":
		print(name)
		hp -= 1.0
	elif teil.name == "Rest":
		print(name)
		hp -= 0.2
	
	if hp <= 1:
		queue_free()
		return
	
	fire_fx.amount_ratio = hp/100
	fire_fx.lifetime = 0.75 * hp /100
	fire_fx.process_material.scale_max = hp/100
	fire_fx.process_material.initial_velocity_max = 5*hp/100
	smoke_fx.position.y -= 0.01


func _on_basis_body_entered(body3D) -> void:
	if body3D is CharacterBody3D:
		print("you just entered into the fire, sir. why?")
		player._damage(fire_damage)


func _on_spread_timer_timeout():
	var fire_scene_resource = load(self.scene_file_path)
	if not fire_scene_resource:
		return

	var random_direction = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	var random_distance = randf_range(1.0, spread_radius)
	var new_position = self.global_position + random_direction * random_distance
	
	var new_fire = fire_scene_resource.instantiate()
	get_parent().add_child(new_fire)
	new_fire.global_position = new_position
	new_fire.add_to_group("fires")

	spread_timer.start()
