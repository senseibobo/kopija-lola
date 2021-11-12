extends Effect
class_name Weakness

var weakness_amount : float

func apply():
	p.attack_damage -= weakness_amount
	p.update_stats()

func expire():
	if expired: return
	.expire()
	p.attack_damage += weakness_amount
	p.update_stats()
