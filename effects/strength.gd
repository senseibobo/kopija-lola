extends Effect
class_name Strength

var strength_amount : float

func apply():
	p.attack_damage += strength_amount
	p.update_stats()

func expire():
	if expired: return
	.expire()
	p.attack_damage -= strength_amount
	p.update_stats()
