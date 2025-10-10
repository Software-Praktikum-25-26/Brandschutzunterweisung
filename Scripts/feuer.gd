extends Node3D

@export var hp: float = 100.0

@export_group("Growth")
@export var growth_speed: float = 0.1
@export var max_size: float = 5.0
@export var hp_regeneration_base: float = 1.0
@export var max_particle_scale: float = 2.5

@onready var fire_particles: GPUParticles3D = $Feuer_Effekt
@onready var damage_area_shape: CollisionShape3D = $Basis/CollisionShape3D
@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("player")
@onready var damage_timer: Timer = $DamageTimer
@onready var extinguish_area_shape_rest: CollisionShape3D = $Rest/CollisionShape3D

# ADDED: References to the smoke and spark particle nodes.
@onready var smoke_particles: GPUParticles3D = $Feuer_Effekt/Rauch_Effekt
@onready var spark_particles: GPUParticles3D = $Feuer_Effekt/Rauch_Effekt/Funken_Effekt

var fire_damage: int = 10
var initial_damage_area_size: Vector3
var initial_extinguish_area_size_rest: Vector3
var initial_particle_scale: float
var is_being_extinguished: bool = false
var extinguish_cooldown: float = 0.0

# ADDED: Variables to store initial material properties for smoke and sparks.
var initial_smoke_scale: float
var initial_spark_scale: float

func _ready():
	# (Reset logic remains the same)
	if damage_area_shape and damage_area_shape.shape:
		damage_area_shape.shape.size = Vector3(1.143, 0.298, 1.86)
	if extinguish_area_shape_rest and extinguish_area_shape_rest.shape:
		extinguish_area_shape_rest.shape.size = Vector3(1.212, 1.706, 1.861)
	if fire_particles and fire_particles.process_material:
		var mat = fire_particles.process_material
		mat.emission_box_extents = Vector3(0.47, 0.09, 1.0)
		mat.scale_max = 0.2
		
	# Make all particle materials unique to this instance.
	fire_particles.process_material = fire_particles.process_material.duplicate()
	smoke_particles.process_material = smoke_particles.process_material.duplicate()
	spark_particles.process_material = spark_particles.process_material.duplicate()
	
	# (Storing initial sizes remains the same)
	if damage_area_shape and damage_area_shape.shape:
		initial_damage_area_size = damage_area_shape.shape.size
	if extinguish_area_shape_rest and extinguish_area_shape_rest.shape:
		initial_extinguish_area_size_rest = extinguish_area_shape_rest.shape.size
	if fire_particles and fire_particles.process_material:
		initial_particle_scale = fire_particles.process_material.scale_max
	
	# ADDED: Store the initial scales of the child effect materials.
	initial_smoke_scale = smoke_particles.process_material.scale_max
	initial_spark_scale = spark_particles.process_material.scale_max

func _process(delta: float):
	if extinguish_cooldown > 0:
		extinguish_cooldown -= delta
		if extinguish_cooldown <= 0:
			is_being_extinguished = false
	
	var material = fire_particles.process_material
	var current_size_x = material.emission_box_extents.x
	var size_percentage = clamp(current_size_x / max_size, 0.0, 1.0)
	
	# --- NEW: Sync Child Effect Materials ---
	# Scale the material properties of smoke and sparks based on the fire's size.
	var smoke_mat = smoke_particles.process_material
	var spark_mat = spark_particles.process_material
	
	smoke_mat.scale_max = lerp(initial_smoke_scale, initial_smoke_scale * 3.0, size_percentage)
	spark_mat.scale_max = lerp(initial_spark_scale, initial_spark_scale * 3.0, size_percentage)
	
	if is_being_extinguished:
		# --- SHRINK LOGIC ---
		# The bigger the fire, the slower it shrinks.
		var shrink_resistance = 1.0 + (size_percentage * 4.0)
		var shrink_speed = growth_speed / shrink_resistance
		
		var new_x = move_toward(current_size_x, 0.0, shrink_speed * delta) # <-- The fix is here
		material.emission_box_extents.x = new_x
		material.emission_box_extents.z = new_x
		
		# Shrink particle scale.
		material.scale_max = move_toward(material.scale_max, initial_particle_scale, (max_particle_scale / 10.0) * shrink_speed * delta)
		
		# Shrink damage and extinguish areas.
		damage_area_shape.shape.size.x = move_toward(damage_area_shape.shape.size.x, initial_damage_area_size.x, shrink_speed * delta)
		damage_area_shape.shape.size.z = move_toward(damage_area_shape.shape.size.z, initial_damage_area_size.z, shrink_speed * delta)
		extinguish_area_shape_rest.shape.size.x = move_toward(extinguish_area_shape_rest.shape.size.x, initial_extinguish_area_size_rest.x, shrink_speed * delta)
		extinguish_area_shape_rest.shape.size.z = move_toward(extinguish_area_shape_rest.shape.size.z, initial_extinguish_area_size_rest.z, shrink_speed * delta)

		# Update HP based on the new, smaller size.
		hp = (material.emission_box_extents.x / max_size) * 100.0
		if hp <= 0.1: # Using a small threshold to be safe
			queue_free()

	else:
		# --- GROW LOGIC ---
		var dynamic_regen = hp_regeneration_base + (size_percentage * 8)
		hp = min(hp + dynamic_regen * delta, 100.0)
		
		# Grow emission area.
		var new_x = move_toward(current_size_x, max_size, growth_speed * delta)
		material.emission_box_extents.x = new_x
		material.emission_box_extents.z = new_x
		
		# Grow particle scale.
		var target_scale = initial_particle_scale * max_particle_scale
		material.scale_max = move_toward(material.scale_max, target_scale, (target_scale / 10.0) * delta)
		
		# Grow damage and extinguish areas.
		damage_area_shape.shape.size.x = move_toward(damage_area_shape.shape.size.x, initial_damage_area_size.x * max_size, growth_speed * delta)
		damage_area_shape.shape.size.z = move_toward(damage_area_shape.shape.size.z, initial_damage_area_size.z * max_size, growth_speed * delta)
		extinguish_area_shape_rest.shape.size.x = move_toward(extinguish_area_shape_rest.shape.size.x, initial_extinguish_area_size_rest.x * max_size, growth_speed * delta)
		extinguish_area_shape_rest.shape.size.z = move_toward(extinguish_area_shape_rest.shape.size.z, initial_extinguish_area_size_rest.z * max_size, growth_speed * delta)

func extinguish(teil: Object):
	is_being_extinguished = true
	extinguish_cooldown = 1.0 # Reset the cooldown timer.
	
func _on_basis_body_entered(body3D):
	if body3D is CharacterBody3D:
		player._damage(fire_damage)
		damage_timer.start()

func _on_basis_body_exited(body3D):
	if body3D is CharacterBody3D:
		damage_timer.stop()

func _on_damage_timer_timeout():
	player._damage(fire_damage)
