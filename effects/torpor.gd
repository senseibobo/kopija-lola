extends Effect
class_name Torpor

var torpor_amount : float
var old_attack_speed : float
var return_attack_speed : float

func apply():
	old_attack_speed = p.attack_speed
	p.attack_speed *= 1-torpor_amount
	return_attack_speed = old_attack_speed - p.attack_speed
	p.update_stats()

func expire():
	if expired: return
	.expire()
	p.attack_speed += return_attack_speed
	p.update_stats()
