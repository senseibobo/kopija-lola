extends Effect
class_name Stun


func apply():
	p.moveable -=1
	p.able_to_basic -= 1
	p.castable -= 1
	
func expire():
	if expired: return
	.expire()
	p.moveable +=1
	p.able_to_basic += 1
	p.castable += 1
