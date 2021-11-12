extends Effect
class_name Ghosting


func apply():
	p.ghosting += 1
	
func expire():
	if expired: return
	.expire()
	p.ghosting -= 1
