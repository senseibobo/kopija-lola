extends Effect
class_name Slow

var slow_percentage : float
var return_speed : float

func apply():
	.apply()
	p.update_stats()

func expire():
	if expired: return
	.expire()
	p.update_stats()
