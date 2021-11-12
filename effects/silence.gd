extends Effect
class_name Silence


func apply():
	p.castable -= 1
	
func expire():
	if expired: return
	.expire()
	p.castable += 1
