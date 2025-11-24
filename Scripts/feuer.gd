extends Node3D

@export var hp = 100
@export var spread_radius: float = 7.0

# Wind effect settings
@export_group("Wind Effects")
@export var max_area_slide_distance: float = 3.0  # Max distance top area slides at force 100
@export var max_particle_velocity_boost: float = 5.0  # Max velocity added at force 100
@export var wind_effect_threshold: float = 20.0  # Wind force below this has minimal effect

@onready var fire_fx = $Feuer_Effekt
@onready var smoke_fx = $Feuer_Effekt/Rauch_Effekt
@onready var rest_area = $Rest  # Top area that will slide
@onready var player: CharacterBody3D = $"../Player"
@onready var spread_timer: Timer = $Spread_Timer

var fire_damage = 10
var wind_gizmo: Node3D = null
var rest_area_original_position: Vector3

func _ready():
	# Duplicate the shared material so it's unique to this instance
	fire_fx.process_material = fire_fx.process_material.duplicate()
	smoke_fx.process_material = smoke_fx.process_material.duplicate()
	
	# Store original position of Rest area
	rest_area_original_position = rest_area.position
	
	# Find the wind gizmo in the scene
	_find_wind_gizmo()
	
	spread_timer.start()

func _find_wind_gizmo():
	# Look for a node with the wind_gizmo.gd script
	var root = get_tree().root
	for child in root.get_children():
		wind_gizmo = _search_for_wind_gizmo(child)
		if wind_gizmo:
			print("Fire found WindGizmo: ", wind_gizmo.name)
			return
	
	if not wind_gizmo:
		push_warning("WindGizmo not found in scene! Fire will not react to wind.")

func _search_for_wind_gizmo(node: Node) -> Node3D:
	# Check if this node has the wind gizmo script
	if node.has_method("get_global_wind_direction") and node.has_method("get_wind_force"):
		return node
	
	# Search children
	for child in node.get_children():
		var result = _search_for_wind_gizmo(child)
		if result:
			return result
	
	return null

func _process(_delta):
	if wind_gizmo:
		_apply_wind_effects()

func _apply_wind_effects():
	var wind_dir = wind_gizmo.get_global_wind_direction()
	var wind_force = wind_gizmo.get_wind_force()
	
	# Only apply wind if above threshold
	if wind_force < wind_effect_threshold:
		# Reset to original position if wind is too weak
		rest_area.position = rest_area_original_position
		_reset_particle_velocity()
		return
	
	# Calculate wind influence (0 to 1, where 1 is max force)
	var wind_influence = clamp((wind_force - wind_effect_threshold) / (100.0 - wind_effect_threshold), 0.0, 1.0)
	
	# 1. Slide the Rest area in wind direction
	var slide_distance = wind_influence * max_area_slide_distance
	var wind_dir_local = global_transform.basis.inverse() * wind_dir  # Convert to local space
	rest_area.position = rest_area_original_position + wind_dir_local * slide_distance
	
	# 2. Adjust particle velocity
	var velocity_boost = wind_influence * max_particle_velocity_boost
	
	# For fire particles
	if fire_fx.process_material is ParticleProcessMaterial:
		var fire_mat = fire_fx.process_material as ParticleProcessMaterial
		# Convert wind direction to local space for particles
		var local_wind = global_transform.basis.inverse() * wind_dir
		fire_mat.direction = local_wind + Vector3.UP
		fire_mat.initial_velocity_min = velocity_boost * 0.8
		fire_mat.initial_velocity_max = velocity_boost + (5 * hp / 100)
	
	# For smoke particles
	if smoke_fx.process_material is ParticleProcessMaterial:
		var smoke_mat = smoke_fx.process_material as ParticleProcessMaterial
		var local_wind = global_transform.basis.inverse() * wind_dir
		smoke_mat.direction = local_wind
		smoke_mat.initial_velocity_min = velocity_boost * 0.5
		smoke_mat.initial_velocity_max = velocity_boost * 0.7

func _reset_particle_velocity():
	# Reset particles to default upward behavior
	if fire_fx.process_material is ParticleProcessMaterial:
		var fire_mat = fire_fx.process_material as ParticleProcessMaterial
		fire_mat.direction = Vector3.UP
		fire_mat.initial_velocity_min = 0
		fire_mat.initial_velocity_max = 5 * hp / 100

	if smoke_fx.process_material is ParticleProcessMaterial:
		var smoke_mat = smoke_fx.process_material as ParticleProcessMaterial
		smoke_mat.direction = Vector3.UP
		smoke_mat.initial_velocity_min = 0
		smoke_mat.initial_velocity_max = 2

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
	# Note: initial_velocity is now controlled by wind in _process
	smoke_fx.position.y -= 0.01

func _on_basis_body_entered(body3D) -> void:
	if body3D is CharacterBody3D:
		print("you just entered into the fire, sir. why?")
		player._damage(fire_damage)

func _on_spread_timer_timeout():
	var fire_scene_resource = load(self.scene_file_path)
	if not fire_scene_resource:
		return
	
	# Spread WITH the wind
	var base_direction = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	
	# Add wind influence to spread direction
	if wind_gizmo:
		var wind_dir = wind_gizmo.get_global_wind_direction()
		var wind_force = wind_gizmo.get_wind_force()
		if wind_force > wind_effect_threshold:
			var wind_influence = clamp(wind_force / 100.0, 0.0, 1.0)
			# Blend random direction with wind direction
			base_direction = base_direction.lerp(wind_dir, wind_influence * 0.7)
			base_direction = base_direction.normalized()
	
	var random_distance = randf_range(1.0, spread_radius)
	var new_position = self.global_position + base_direction * random_distance
	
	var new_fire = fire_scene_resource.instantiate()
	get_parent().add_child(new_fire)
	new_fire.global_position = new_position
	new_fire.add_to_group("fires")
	spread_timer.start()
