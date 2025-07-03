extends Node3D


@export var hp = 100
@onready var fire_fx = $Feuer_Effekt
@onready var smoke_fx = $Feuer_Effekt/Rauch_Effekt
@onready var player: CharacterBody3D = $"../Player"
var fire_damage = 10


func _ready():
	# Duplicate the shared material so it's unique to this instance
	fire_fx.process_material = fire_fx.process_material.duplicate()

func extinguish(teil: Object):
	
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
