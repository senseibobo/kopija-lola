extends Effect
class_name Speed

var speed_percentage : float
var return_speed : float

func apply():
	.apply()
	p.update_stats()

func expire():
	if expired: return
	.expire()
	p.update_stats()
