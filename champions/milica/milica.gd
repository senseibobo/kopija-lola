extends Champion

var passive_cd : float = 0.0

var milica_basic_scene = preload("res://champions/milica/basic/malter.tscn")
var traveller_scene = preload("res://champions/milica/traveller/traveller.tscn")
var surface_scene = preload("res://champions/milica/surface/surface.tscn")
var dashed : bool = false
var dashing : bool = false
export var dash_time : float = 0.2
export var dash_speed : float = 1200
var dashing_timer : float = 0.0 
var dash_dir : Vector2
var shield_amount : float setget ,get_shield_amount
var shield_duration : float setget ,get_shield_duration
var garlic_speed_percentage : float setget ,get_garlic_speed_percentage
var garlic_speed_duration : float setget ,get_garlic_speed_duration
var passive_speed_percentage : float setget ,get_passive_speed_percentage
var passive_speed_duration : float setget ,get_passive_speed_duration
var passive_boost_percentage : float setget ,get_passive_boost_percentage
var basic_slow_percentage : float setget ,get_basic_slow_percentage
var basic_slow_duration : float setget ,get_basic_slow_duration
var traveller_damage : float setget ,get_traveller_damage
var surface_dps : float setget ,get_surface_dps
var surface_duration : float setget ,get_surface_duration
var surface_slow_percentage : float setget ,get_surface_slow_percentage
var surface_range : float setget ,get_surface_range
var surface_angle : float setget ,get_surface_angle

func get_shield_amount():
	return 100 + ability_levels[2]*70
func get_shield_duration():
	return 5 + ability_levels[2]*1
func get_garlic_speed_percentage():
	return 40
func get_garlic_speed_duration():
	return 5
func get_passive_speed_percentage():
	return 40
func get_passive_speed_duration():
	return 1
func get_passive_boost_percentage():
	return 10 + 2*level
func get_basic_slow_percentage():
	return 20
func get_basic_slow_duration():
	return 1
func get_traveller_damage():
	return 30 + 5*ability_levels[1] + 0.6*attack_damage 
func get_surface_dps():
	return 125
func get_surface_duration():
	return 5
func get_surface_slow_percentage():
	return 50
func get_surface_range():
	return 1000
func get_surface_angle():
	return 45

func _ready():
	if get_tree().is_network_server():
		self.connect("taken_damage",self,"on_damage_taken")

func on_damage_taken(total_damage,source):
	apply_passive_buff()

func apply_passive_buff():
	var effect = Speed.new( )
	effect.duration = get_passive_speed_duration()
	effect.speed_percentage = get_passive_speed_percentage()/100.0
	effect.name = "MILICA_PASSIVE"
	effect.effect_owner = self
	rpc("apply_effect",inst2dict(effect))
	effect = Strength.new()
	effect.duration = get_passive_speed_duration()
	effect.strength_amount = 10
	effect.name = "MILICA_PASSIVE"
	effect.effect_owner = self
	rpc("apply_effect",inst2dict(effect))

func _process(delta):
	passive_cd = move_toward(passive_cd,0,delta)
	if dashing:
		global_position += dash_dir*dash_speed*delta
		dashing_timer = move_toward(dashing_timer,0,delta)
		if dashing_timer <= 0:
			end_dash()

func end_dash():
	dashing = false
	moveable += 1
	castable += 1
	able_to_basic += 1
	dashed = true
	global_position = Game.get_closest_point_to(global_position)

func apply_basic_debuff(target):
	var effect = Slow.new()
	effect.duration = get_basic_slow_duration()
	effect.slow_percentage = get_basic_slow_percentage()/100.0
	effect.name = "MILICA_BASIC"
	effect.effect_owner = self
	target.rpc("apply_effect",inst2dict(effect))

func on_basic_hit(target):
	apply_basic_debuff(target)

remotesync func basic_attack(args):
	if not is_instance_valid(target): return
	var damage = Damage.new()
	damage.physical_damage = attack_damage
	damage.crit_percent += 1 if fmod(args[ARGS.RANDOM],100)<100*critical_chance else 0
	var proj = milica_basic_scene.instance()
	proj.projectile_owner = self
	proj.target = get_node(args[ARGS.TARGET_ENEMY_PATH])
	proj.name = args[ARGS.NAME]
	proj.global_position = args[ARGS.GPOS]
	proj.homing = true
	proj.team = team
	proj.damage = damage
	if get_tree().is_network_server():
		proj.connect("hit_enemy",self,"on_basic_hit")
	Game.get_projectile_node().add_child(proj)

remotesync func traveller_expire():
	apply_cooldown(1)
	dashed = false

remotesync func first_ability(args):
	if not dashed:
		dashing = true
		dashing_timer = dash_time
		moveable -= 1
		castable -= 1
		able_to_basic -= 1
		dash_dir = global_position.direction_to(args[ARGS.MPOS])
		if get_tree().is_network_server():
			yield(get_tree().create_timer(5),"timeout")
			if dashed:
				rpc("traveller_expire")
	else:
		var damage = Damage.new()
		damage.physical_damage = get_traveller_damage()#
		var proj = traveller_scene.instance()
		proj.projectile_owner = self
		proj.name = args[ARGS.NAME]
		proj.global_position = args[ARGS.GPOS]
		proj.homing = false
		proj.team = team
		proj.damage = damage
		proj.direction = global_position.direction_to(args[ARGS.MPOS])
		dashed = false
		Game.get_projectile_node().add_child(proj)
		apply_cooldown(1)
	set_mana(current_mana - mana_costs[1])
		
remotesync func second_ability(args):
	for effect in effects:
		var e = effects[effect] as Effect
		if e.root or e.stun or bool(e.knockback) or e.silence or e.slow or e.fear or e.charm or e.disarm:
			remove_effect(effect)
	if get_tree().is_network_server():
		var effect = Shield.new()
		effect.duration = get_shield_duration()
		effect.shield_amount = get_shield_amount()
		effect.effect_owner = self
		effect.name = "GARLIC_SHIELD"
		rpc("apply_effect",inst2dict(effect))
		effect = Speed.new()
		effect.duration = get_garlic_speed_duration()
		effect.speed_percentage = get_garlic_speed_percentage()/100.0
		effect.name = "GARLIC_SPEED"
		effect.effect_owner = self
		rpc("apply_effect",inst2dict(effect))
	apply_cooldown(2)
	set_mana(current_mana - mana_costs[2])
			
remotesync func ultimate_ability(args):
	var surface = surface_scene.instance()
	surface.surface_damage_per_second = get_surface_dps()
	surface.surface_duration = get_surface_duration()
	surface.team = team
	surface.direction = args[ARGS.GPOS].direction_to(args[ARGS.MPOS])
	surface.radius = get_surface_range()
	surface.angle = get_surface_angle()
	surface.slow_percentage = get_surface_slow_percentage()
	surface.global_position = args[ARGS.GPOS]
	surface.milica = self
	Game.get_projectile_node().add_child(surface)
	apply_cooldown(3)
	set_mana(current_mana - mana_costs[3])


	
	
	
	
	
