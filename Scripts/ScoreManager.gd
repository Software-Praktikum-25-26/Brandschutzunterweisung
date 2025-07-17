extends Node

#holds score
var current_score: int = 0

#resets score
func reset_score():
	current_score = 0

#reduce score
func decrease_score(amount: int):
	current_score -= amount
	if current_score < 0:
		current_score = 0

#increase score
func increase_score(amount: int):
	current_score += amount
