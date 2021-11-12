extends Effect
class_name Curse

var tick_damage : float
var total_damage : float
var tick_rate : float = 0.1
var tick_timer : float = 0.0


func _process(delta):
	if p.get_tree().is_network_server():
		tick_timer -= delta
		if tick_timer <= 0:
			tick_timer += tick_rate
			p.rpc("apply_damage",Dicts.damage_to_dict(tick_damage),p.get_path_to(effect_owner))

func apply_damage(damage_amount):
	var damage = Damage.new()
	damage.true_damage = damage_amount
	p.apply_damage(damage)
