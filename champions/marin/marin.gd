extends Champion

export var pa_base : float = 30.0
export var pa_ap_scale : float = 0.05
export var pa_lvl_scale : float = 6
export var ph_base : float = 60.0
export var ph_ap_scale : float = 0.1
export var ph_lvl_scale : float = 10
var bs_dashing : bool = false
var bs_direction : Vector2
var bs_dash_area : Area2D
export var bs_speed : float = 600
export var bs_duration : float = 0.5
export var bs_base : float = 50
export var bs_max_hp_scale : float = 0.05
export var bs_slow_percent : float = 0.3
var old_gpos : Vector2
var time_dormant : float = 0.0
onready var marin_basic_scene = preload("res://champions/marin/basic/marinbasic.tscn")
onready var pokazivac_scene = preload("res://champions/marin/pokazivac/pokazivac.tscn")
var odmor_speed_percentage : float setget ,get_odmor_speed_percentage
var odmor_speed_duration : float setget ,get_odmor_speed_duration
var min_odmor : float setget ,get_min_odmor
var max_odmor : float setget ,get_max_odmor
var basic_damage : float setget ,get_basic_damage
var char_damage : float setget ,get_char_damage
var hex_damage : float setget ,get_hex_damage
var slam_damage : float setget ,get_slam_damage
var slam_slow_percentage : float setget ,get_slam_slow_percentage
var slam_slow_duration : float setget ,get_slam_slow_duration
var glas_slow_percentage : float setget ,get_glas_slow_percentage
var glas_slow_duration : float setget ,get_glas_slow_duration
var glas_speed_percentage : float setget ,get_glas_speed_percentage
var glas_speed_duration : float setget ,get_glas_speed_duration

func get_min_odmor():
	return 1.5
func get_max_odmor():
	return 3
func get_odmor_speed_percentage():
	return 100
func get_odmor_speed_duration():
	return 1.5
func get_basic_damage():
	return attack_damage
func get_char_damage():
	return 10+0.05*ability_power+5*ability_levels[1]
func get_hex_damage():
	return 20+0.2*ability_power+15*ability_levels[1]
func get_slam_damage():
	return 50+0.05*health
func get_slam_slow_percentage():
	return 30
func get_slam_slow_duration():
	return 2
func get_glas_slow_percentage():
	return 40
func get_glas_slow_duration():
	return 5
func get_glas_speed_percentage():
	return 30
func get_glas_speed_duration():
	return 5
	
remotesync func basic_attack(args):
	if not is_instance_valid(target): return
	var damage = Damage.new()
	damage.physical_damage = get_basic_damage()
	damage.crit_percent += 1 if fmod(args[ARGS.RANDOM],100)<100*critical_chance else 0
	var proj = marin_basic_scene.instance()
	proj.projectile_owner = self
	proj.number = int(args[ARGS.RANDOM])%10
	proj.target = get_node(args[ARGS.TARGET_ENEMY_PATH])
	proj.name = args[ARGS.NAME]
	proj.global_position = args[ARGS.GPOS]
	proj.homing = true
	proj.team = team
	proj.damage = damage
	Game.get_projectile_node().add_child(proj)
remotesync func first_ability(args):
	var pokazivac = pokazivac_scene.instance()
	pokazivac.pokazivac_owner = self
	pokazivac.base_attack_speed = attack_speed+0.5
	pokazivac.basic_damage = Damage.new()
	pokazivac.basic_damage.magic_damage = get_char_damage()
	pokazivac.hex_damage = Damage.new()
	pokazivac.hex_damage.magic_damage = get_hex_damage()
	pokazivac.team = team
	pokazivac.global_position = Game.get_closest_point_to(args[ARGS.MPOS])
	pokazivac.name = args[ARGS.NAME]
	set_mana(current_mana - mana_costs[1])
	apply_cooldown(1)
	Game.get_pentity_node().add_child(pokazivac)

remotesync func second_ability(args):
	moveable -= 1
	able_to_basic -= 1
	castable -= 1
	bs_dashing = true
	bs_direction = global_position.direction_to(args[ARGS.MPOS])
	set_mana(current_mana - mana_costs[2])
	apply_cooldown(2,1000)
	var timer = Timer.new(); add_child(timer); timer.start(bs_duration); yield(timer,"timeout"); timer.queue_free()
	if bs_dashing:
		end_dash()

func slow_bodies(entity_paths):
	for entity_path in entity_paths:
		var entity = get_node(entity_path)
		var effect = Slow.new()
		effect.duration = get_glas_slow_duration()
		effect.slow_percentage = get_glas_slow_percentage()/100.0
		effect.name = "MARIN_ULT_SLOW"
		effect.effect_owner = self
		entity.rpc("apply_effect",inst2dict(effect))

remotesync func ultimate_ability(args):
	if get_tree().is_network_server():
		var bodies = []
		for player in Game.get_players_in_range(global_position,500,team,true):
			bodies.append(get_path_to(player))
		if bodies != []: 
			slow_bodies(bodies)
		var effect = Speed.new()
		effect.duration = get_glas_speed_duration()
		effect.speed_percentage = get_glas_speed_percentage()/100.0
		effect.name = "MARIN_SELF_SPEED"
		effect.effect_owner = self
		rpc("apply_effect",inst2dict(effect))
	
	apply_cooldown(3)
	reset_cooldown(1)
	reset_cooldown(2)
	set_health(health)
	set_mana(mana)
	VFX.create_effect(VFX.EXPLOSION,global_position,Color(1,0.2,0.2),5.0)

remotesync func end_dash():
	moveable += 1
	able_to_basic += 1
	castable += 1
	bs_dashing = false
	global_position = Game.get_closest_point_to(global_position)
	apply_cooldown(2)

remotesync func dash_hit(entity_paths : Array):
	var damage = Damage.new()
	damage.physical_damage = get_slam_damage()
	if get_tree().is_network_server():
		for entity_path in entity_paths:
			var entity = get_node(entity_path)
			entity.take_damage(Dicts.damage_to_dict(damage),entity.get_path_to(self))
			var effect = Slow.new()
			effect.duration = get_slam_slow_duration()
			effect.slow_percentage = get_slam_slow_percentage()/100.0
			effect.name = "MARIN_BODY_SLAM_SLOW"
			effect.effect_owner = self
			entity.rpc("apply_effect",inst2dict(effect))
		rpc("end_dash")

func apply_odmor_buff(amount):
	var effect = Speed.new()
	effect.speed_percentage = amount*get_odmor_speed_percentage()/100.0
	effect.duration = get_odmor_speed_duration()
	effect.name = "MARIN_ODMOR"
	effect.effect_owner = self
	rpc("apply_effect",inst2dict(effect))
	

func _process(delta):
	if get_tree().is_network_server():
		if old_gpos == global_position:
			time_dormant = move_toward(time_dormant,get_max_odmor(),delta)
		else:
			if time_dormant >= get_min_odmor():
				apply_odmor_buff(time_dormant/get_max_odmor())
			time_dormant = 0.0
		
	old_gpos = global_position
	if bs_dashing:
		global_position += bs_direction * bs_speed * delta
		if get_tree().is_network_server():
			var bodies = Optimizations.check_collision_gameplay(self,team,true)
			var bodies_hit = []
			for body in bodies:
				if "is_champion" in body: bodies_hit.append(get_path_to(body))
			if bodies_hit != []:
				rpc("dash_hit",bodies_hit)
		
