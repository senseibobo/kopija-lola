extends Champion

var passive_shield_time : float = 0.0 setget set_passive_shield_time
var passive_shield_delay : float = 0.0 setget ,get_passive_shield_delay
var passive_shield_amount : float = 0.0 setget ,get_passive_shield_amount
var passive_speed_bonus_percentage : float = 0.0 setget ,get_passive_speed_bonus_percentage
var passive_speed_current_time : float setget set_passive_speed_current_time
var passive_speed_max_time : float setget ,get_passive_speed_max_time
var fudbal_min_time : float setget ,get_fudbal_min_time
var fudbal_max_time : float setget ,get_fudbal_max_time
var fudbal_damage : float setget ,get_fudbal_damage
var fudbal_max_damage : float setget ,get_fudbal_max_damage
var tenis_min_time : float setget ,get_tenis_min_time
var tenis_max_time : float setget ,get_tenis_max_time
var tenis_return_percentage : float setget ,get_tenis_return_percentage

var old_pos : Array = [Vector2(),Vector2()]

func set_passive_shield_time(value): passive_shield_time = value
func get_passive_shield_delay(): return 10.0
func get_passive_shield_amount(): return 60.0+level*30.0
func get_passive_speed_bonus_percentage(): return 35.0
func set_passive_speed_current_time(value): passive_speed_current_time = value
func get_passive_speed_max_time(): return 7.0
func get_passive_speed_min_time(): return 4.0
func get_fudbal_min_time(): return 0.2
func get_fudbal_max_time(): return 2.0
func get_fudbal_damage(): return 20.0+ability_levels[1]*10.0+attack_damage*0.5
func get_fudbal_max_damage(): return 50.0+ability_levels[1]*20.0+attack_damage*0.6+get_fudbal_damage()
func get_tenis_min_time(): return 0.2
func get_tenis_max_time(): return 2.0
func get_tenis_return_percentage(): return 50.0

const PASSIVE_TICK : float = 0.2
const basic_scene : PackedScene = preload("res://champions/vladimir/basic/vladimirbasic.tscn")
const fudbal_scene : PackedScene = preload("res://champions/vladimir/first/fudbal.tscn")

var fudbal_cast : bool = false
var is_in_tennis : bool = false
var total_tennis_damage : float = 0.0

func on_damage_taken(total_damage,source):
	set_passive_shield_time(0.0)

func _ready():
	if get_tree().is_network_server():
		var speed_tick_timer = Timer.new()
		speed_tick_timer.connect("timeout",self,"_passive_speed_tick")
		add_child(speed_tick_timer)
		speed_tick_timer.start(PASSIVE_TICK)
	connect("taken_damage",self,"on_damage_taken")
	connect("channel_finished",self,"channeling_finished")

func _passive_speed_tick():
	if passive_speed_current_time > get_passive_speed_min_time():
		var effect = Speed.new()
		effect.speed_percentage = get_passive_speed_bonus_percentage() * min(passive_speed_current_time,get_passive_speed_max_time())/get_passive_speed_max_time()/100.0
		effect.name = "VLADIMIR_PASSIVE_SPEED"
		effect.duration = PASSIVE_TICK*2.0
		effect.effect_owner = self
		rpc("apply_effect",inst2dict(effect))
		

func _process(delta):
	#print(is_in_tennis)
	if old_pos[1] == global_position:
		passive_speed_current_time = 0.0
		remove_effect("VLADIMIR_PASSIVE_SPEED")
	else:
		passive_speed_current_time += delta
	old_pos[1] = old_pos[0]
	old_pos[0] = global_position
	if get_tree().is_network_server() and passive_shield_time > get_passive_shield_delay() and not has_effect("VLADIMIR_PASSIVE_SHIELD"):
		var effect = Shield.new()
		effect.effect_owner = self
		effect.name = "VLADIMIR_PASSIVE_SHIELD"
		effect.shield_amount = get_passive_shield_amount()
		rpc("apply_effect",inst2dict(effect))
	
remotesync func basic_attack(args):
	var t = get_node_or_null(args[ARGS.TARGET_ENEMY_PATH])
	if not is_instance_valid(t): return
	var damage = Damage.new()
	damage.physical_damage = attack_damage
	damage.crit_percent += 1 if fmod(args[ARGS.RANDOM],100) < 100*critical_chance else 0
	var proj = Projectile.new()
	proj.global_position = args[ARGS.GPOS]
	proj.target = t
	proj.speed = 10000
	proj.damage = damage
	proj.projectile_owner = self
	proj.name = args[ARGS.NAME]
	Game.get_projectile_node().add_child(proj)
	var basic = basic_scene.instance()
	basic._range = attack_range
	basic.attack_speed = attack_speed
	basic.direction = global_position.direction_to(t.global_position)
	add_child(basic)

func channeling_finished(cname):
	if not is_network_master(): return
	match cname:
		"Fudbal":
			rpc_id(1,"_server_release_ability",1,get_ability_args())
		"Tenis":
			rpc_id(1,"_server_release_ability",2,get_ability_args())

remotesync func first_ability(args):
	fudbal_cast = false
	start_channeling("Fudbal",get_fudbal_max_time(),Color.green,true)

remotesync func first_ability_release(args):
	if last_channeled == "Fudbal" and not fudbal_cast:
		fudbal_cast = true
		call_deferred("cast_fudbal",args,last_channeling_timer)
		
func cast_fudbal(args,time):
	var fudbal = fudbal_scene.instance()
	var damage = Damage.new()
	var p = clamp(time,get_fudbal_min_time(),get_fudbal_max_time())/get_fudbal_max_time()/get_fudbal_max_time()
	damage.physical_damage = get_fudbal_damage()+(get_fudbal_max_damage()-get_fudbal_damage())*p
	fudbal.damage = damage
	fudbal.projectile_owner = self
	fudbal.name = args[ARGS.NAME]
	fudbal.global_position = args[ARGS.GPOS]
	print(time)
	fudbal.direction = args[ARGS.GPOS].direction_to(args[ARGS.MPOS])
	Game.get_projectile_node().add_child(fudbal) 

remotesync func second_ability(args):
	start_channeling("Tenis",get_tenis_max_time(),Color.blue,true)
	is_in_tennis = true
	total_tennis_damage = 0.0

remotesync func second_ability_release(args):
	if last_channeled == "Tenis":
		call_deferred("cast_tenis",args,last_channeling_timer)

func cast_tenis(args,time):
	is_in_tennis = false

remotesync func issue_damage(dmg,source_path):
	if not is_in_tennis:
		.issue_damage(dmg,source_path)
	else:	
		var total_damage : float = 0.0
		total_damage += dmg[0]
		total_damage += dmg[1]
		total_damage += dmg[2]
		total_damage += dmg[3]
		total_tennis_damage += total_damage


remotesync func ultimate_ability(args):
	pass
