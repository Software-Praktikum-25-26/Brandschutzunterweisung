extends "res://Scripts/feuer.gd" # Inherit your existing fire logic

var is_reigniting = false

func extinguish(teil: Object):
	super.extinguish(teil) # Keep your old health logic
	
	if hp <= 5 and not is_reigniting:
		is_reigniting = true
		fire_fx.emitting = false # Make it look "out"
		await get_tree().create_timer(3.0).timeout
		
		# If the player didn't "over-kill" it, it comes back!
		if hp < 20: 
			hp = 60
			fire_fx.emitting = true
			is_reigniting = false
			print("Rückzündung!")
