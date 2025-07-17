extends Node3D

# link UI Label from the editor.
@export var score_label: Label

# update score
func _process(delta):
	#signal score manager
	ScoreManager.decrease_score(1)
	
	#get score
	score_label.text = "Score: " + str(ScoreManager.current_score)


func _on_spread_timer_timeout() -> void:
	pass # Replace with function body.
