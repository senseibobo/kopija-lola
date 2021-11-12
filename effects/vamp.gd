extends Effect
class_name Vamp

var vamp_amount : float

func apply():
	p.life_steal += vamp_amount
	p.update_stats()

func expire():
	if expired: return
	.expire()
	p.life_steal -= vamp_amount
	p.update_stats()
