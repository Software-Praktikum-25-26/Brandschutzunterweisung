extends Node3D

@export var hp = 100

@onready var fire_fx = $Feuer_Effekt
@onready var smoke_fx = $Feuer_Effekt/Rauch_Effekt



func _ready():
	# Duplicate the shared material so it's unique to this instance
	fire_fx.process_material = fire_fx.process_material.duplicate()

func extinguish(teil: Object):
	print(name)
	if teil.name == "Basis":
		hp -= 1.0
	elif teil.name == "Rest":
		hp -= 0.2
	
	if hp <= 1:
		queue_free()
		return
	
	fire_fx.amount_ratio = hp/100
	fire_fx.lifetime = 0.75 * hp /100
	fire_fx.process_material.scale_max = hp/100
	fire_fx.process_material.initial_velocity_max = 5*hp/100
	smoke_fx.position.y -= 0.01
