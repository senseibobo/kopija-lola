extends Effect
class_name Disarm



func apply():
	p.able_to_basic -= 1
	
func expire():
	if expired: return
	.expire()
	p.able_to_basic += 1
