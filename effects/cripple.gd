extends Effect
class_name Cripple

var cripple_amount : float

func apply():
	p.add_cripple(cripple_amount)

func expire():
	if expired: return
	.expire()
