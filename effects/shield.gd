extends Effect
class_name Shield

var shield_amount : float

func apply():
	p.add_shield(shield_amount)

func expire():
	if expired: return
	.expire()
