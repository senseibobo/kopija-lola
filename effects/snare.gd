extends Effect
class_name Snare

func apply():
	p.moveable -= 1
	
func expire():
	if expired: return
	.expire()
	p.moveable += 1
