extends Effect
class_name Fear

var entity_to_fear
var entity
var return_speed : float

func apply():
	entity = p.get_node(entity_to_fear)
	p.moveable -= 1

func _process(delta):
	._process(delta)
	if p.moveable >= 0:
		var espeed = p.movement_speed*0.5
		var new_pos = p.global_position.move_toward(entity.global_position,-espeed*delta)
		p.global_position = Game.get_closest_point_to(new_pos)
	

func expire():
	if expired: return
	.expire()
	p.moveable += 1
