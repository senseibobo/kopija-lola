extends Sleep
class_name SreckoSleep

func wake_up(total_damage,source):
	.wake_up(total_damage,source)
	if p.get_tree().is_network_server():
		for entity in Game.get_entities(p.team):
			if entity.has_effect(name):
				entity.call_deferred("rpc","remove_effect",name)
