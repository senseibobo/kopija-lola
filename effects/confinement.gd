extends Effect
class_name Confinement

var confine_pos
var confine_radius


func _process(delta):
	var dir = confine_pos.direction_to(p.global_position)
	var dist = confine_pos.distance_to(p.global_position)
	dist = clamp(dist,0,confine_radius)
	p.global_position = confine_pos + dir*dist

func expire():
	if expired: return
	.expire()

