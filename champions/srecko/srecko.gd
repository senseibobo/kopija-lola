extends Champion

signal first_ability
signal second_ability

var basic_index = 0
var basic_string = "SRECKO"
const basic_scene = preload("res://champions/srecko/basic/sreckobasic.tscn")
const button_scene = preload("res://champions/srecko/second/button.tscn")
const radnik_scene = preload("res://champions/srecko/third/radnik.tscn")
var passive_cc_percentage : float setget set_passive_cc_percentage,get_passive_cc_percentage
var basic_damage : float setget set_basic_damage,get_basic_damage
var o_damage : float setget set_o_damage,get_o_damage
var button_damage : float setget set_button_damage,get_button_damage
var sleep_damage : float setget set_sleep_damage,get_sleep_damage
func set_passive_cc_percentage(value): passive_cc_percentage = value
func get_passive_cc_percentage(): return 50
func set_basic_damage(value): basic_damage = value
func get_basic_damage(): return attack_damage
func set_o_damage(value): o_damage = value
func get_o_damage(): return (0.2+0.05*level)*ability_power
func set_button_damage(value): button_damage = value
func get_button_damage(): return 50+0.3*ability_power+ability_levels[1]*20
func set_sleep_damage(value): sleep_damage = value
func get_sleep_damage(): return 100

remotesync func apply_effect(effect_dict):
	var effect = dict2inst(effect_dict)
	if effect is Stun or effect is Slow or effect is Root or effect is Sleep or effect is Fear or effect is Charm or effect is Snare:
		effect.duration *= get_passive_cc_percentage()/100.0
	var new_effect_dict = inst2dict(effect)
	.apply_effect(new_effect_dict)

remotesync func basic_attack(args):
	if not is_instance_valid(target): return
	var damage = Damage.new()
	damage.physical_damage = get_basic_damage()
	if basic_index == basic_string.length()-1: damage.magic_damage = get_o_damage()
	damage.crit_percent += 1 if fmod(args[ARGS.RANDOM],100) < 100*critical_chance else 0
	var proj = basic_scene.instance()
	proj.projectile_owner = self
	proj.get_node("Label").text = basic_string[basic_index]
	proj.name = args[ARGS.NAME]
	proj.global_position = args[ARGS.GPOS]
	proj.team = team
	proj.damage = damage
	proj.target = get_node(args[ARGS.TARGET_ENEMY_PATH])
	Game.get_projectile_node().add_child(proj)
	basic_index=(basic_index+1)%basic_string.length()

remotesync func first_ability(args):
	var direction : Vector2 = args[ARGS.GPOS].direction_to(args[ARGS.MPOS])
	var angle = PI+direction.angle()
	var vfxargs = {
		VFX.ARGS_ROTATION : angle,
		VFX.ARGS_SIZE : 20
	}
	VFX.create_effect(VFX.CONE,global_position,Color.black,7.0,vfxargs)
	if get_tree().is_network_server():
		var entities = Game.get_entities_in_cone(args[ARGS.GPOS], 700.0, -direction, 40, team, true)
		if get_tree().is_network_server():
			for entity in entities:
				var effect = SreckoSleep.new()
				effect.effect_owner = self
				effect.duration = 3.0
				effect.wake_up_damage = get_sleep_damage()
				effect.name = "SRECKO_SLEEP"
				entity.rpc("apply_effect",inst2dict(effect))
	emit_signal("first_ability",args)
	apply_cooldown(1)
	set_mana(current_mana - mana_costs[1])

remotesync func second_ability(args):
	var proj = button_scene.instance()
	proj.global_position = args[ARGS.GPOS]
	proj.damage = Damage.new()
	proj.projectile_owner = self
	proj.team = team
	proj.name = args[ARGS.NAME]
	proj.direction = args[ARGS.GPOS].direction_to(args[ARGS.MPOS])
	proj.connect("hit_enemy",self,"on_button_hit",[proj])
	Game.get_projectile_node().add_child(proj)
	#apply_cooldown(2)
	emit_signal("second_ability",args)
	apply_cooldown(2)
	set_mana(current_mana - mana_costs[2])

remotesync func ultimate_ability(args):
	var radnik = radnik_scene.instance()
	radnik.copy_stats(self)
	radnik.global_position = args[ARGS.GPOS]
	radnik.set_network_master(get_network_master())
	radnik.team = team
	radnik.name = args[ARGS.NAME]
	radnik.pet_owner = self
	connect("first_ability",radnik,"first_ability")
	connect("second_ability",radnik,"second_ability")
	Game.get_pentity_node().add_child(radnik)
	apply_cooldown(3)
	set_mana(current_mana - mana_costs[3])

func on_button_hit(proj,body):
	VFX.create_effect(VFX.EXPLOSION,proj.global_position,Color.white,2.5)
	if get_tree().is_network_server():
		var entities = Game.get_entities_in_range(proj.global_position,250,team,true,false)
		for entity in entities:
			var damage = Damage.new()
			damage.magic_damage = get_button_damage()
			entity.take_damage(Dicts.damage_to_dict(damage),entity.get_path_to(self))
