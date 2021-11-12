extends Node2D

var trougao_owner : Entity
var damage : Damage
var team : int
export var gameplay_radius : float =  1.0
var bodies = []

func _process(delta):
	rotation = fmod(rotation+8*delta,TAU)
	if get_tree().is_network_server():
		var new_bodies = []
		for body in Optimizations.check_collision_gameplay(self,team,true):
			new_bodies.append(body)
		for body in new_bodies:
			if not body in bodies:
				bodies.append(body)
				_trougao_hit(body)
		for body in bodies:
			if not body in new_bodies:
				bodies.erase(body)

func _trougao_hit(body):
	if get_tree().is_network_server() and body.team != team:
		body.take_damage(Dicts.damage_to_dict(damage),body.get_path_to(trougao_owner))
