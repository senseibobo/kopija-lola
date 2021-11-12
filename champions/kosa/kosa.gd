extends Champion

var basic_dir : int = -1
var next_creep_buff : int = 50
export var ad_per_50cs : float = 20.0
onready var swing_scene = preload("res://champions/kosa/basic/kosabasic.tscn")
onready var trougao_scene = preload("res://champions/kosa/trougao/trougao.tscn")
onready var arena_scene = preload("res://champions/kosa/ulti/arena.tscn")
var trouglovi = []
var trouglovi_duration_left : float
var trouglovi_angle : float = 0.0
export var trouglovi_range : float = 250
export var trouglovi_duration : float = 5
onready var trouglovi_node = get_node("Trouglovi")
var ult_timer : Timer = Timer.new()
var passive_ad_per_cs : float setget ,get_passive_ad_per_cs
var passive_cs_required : int setget ,get_passive_cs_required
var attack_boost_percentage : float setget ,get_attack_boost_percentage
var vrisak_fear_duration : float setget ,get_vrisak_fear_duration
var vrisak_root_duration : float setget ,get_vrisak_root_duration
var trougao_time : float setget ,get_trougao_time
var trougao_damage : float setget ,get_trougao_damage
var krug_duration : float setget ,get_krug_duration
var krug_attack_speed : float setget ,get_krug_attack_speed
var krug_life_steal : float setget ,get_krug_life_steal


func get_basic_damage():
	return attack_damage
func get_passive_ad_per_cs():
	return 20.0
func get_passive_cs_required():
	return 50
func get_attack_boost_percentage():
	return 20.0
func get_vrisak_fear_duration():
	return 0.75 + ability_levels[1]* 0.1
func get_vrisak_root_duration():
	return 1.0 + ability_levels[1]*0.1
func get_trougao_time():
	return 5.0
func get_trougao_damage():
	return 20 + ability_levels[2]*10 + attack_damage * 0.1
func get_krug_duration():
	return 10 + ability_levels[3]*1.5
func get_krug_attack_speed():
	return 0.5 + ability_levels[3]*0.1
func get_krug_life_steal():
	return 20 + ability_levels[3]*5

func _ready():
	add_child(ult_timer)
	

func killed_entity(entity):
	.killed_entity(entity)
	if creep_score >= next_creep_buff:
		next_creep_buff += ad_per_50cs
func apply_root(entity_path : String):
	var entity = get_node(entity_path)
	var effect = Root.new()
	effect.name = "KOSA_ROOT"
	effect.duration = get_vrisak_root_duration()
	effect.effect_owner = self
	effect.root = true
	entity.rpc("apply_effect",inst2dict(effect))

remotesync func basic_attack(args):
	if not is_instance_valid(target): return
	var is_edge = (global_position.distance_squared_to(target.global_position) > attack_range * 0.8 *attack_range * 0.8)
	if is_edge: VFX.create_effect(VFX.EXPLOSION,target.global_position, Color.white, 0.33)
	var boost = (1+ (get_attack_boost_percentage()/100.0 if is_edge else 0))
	var target = get_node(args[ARGS.TARGET_ENEMY_PATH])
	var damage = Damage.new()
	damage.physical_damage = get_basic_damage() * boost
	damage.crit_percent += 1 if fmod(args[ARGS.RANDOM],100)<100*critical_chance else 0
	var proj = Projectile.new()
	proj.projectile_owner = self
	proj.speed = 10000
	proj.target = target
	proj.name = args[ARGS.NAME] + "_proj"
	proj.global_position = global_position
	proj.damage = damage
	proj.team = team
	Game.get_projectile_node().add_child(proj)
	if get_tree().is_network_server() and target.has_effect("KOSA_FEAR"):
		apply_root(get_path_to(target))
	basic_dir = -basic_dir
	var swing = swing_scene.instance()
	swing.dir = basic_dir
	swing.angle = (target.global_position - global_position).angle()
	swing.attack_speed = attack_speed
	add_child(swing)
	
func apply_fear(entity_paths):
	for path in entity_paths:
		var entity = get_node(path)
		var effect = Fear.new()
		effect.duration = get_vrisak_fear_duration()
		effect.entity_to_fear = get_path()
		effect.name = "KOSA_FEAR"
		effect.effect_owner = self
		entity.rpc("apply_effect",inst2dict(effect))
		
remotesync func first_ability(args):
	set_mana(current_mana - mana_costs[1])
	apply_cooldown(1)
	if get_tree().is_network_server():
		var entities_in_range = Game.get_entities_in_range(global_position,300,team,true)
		var entities_in_range_paths = []
		for entity in entities_in_range:
			entities_in_range_paths.append(get_path_to(entity))
		if entities_in_range != []:
			apply_fear(entities_in_range_paths)
	VFX.create_effect(VFX.EXPLOSION,global_position,Color.black,3.0)

func _process(delta):
	if trouglovi != []:
		process_trouglovi(delta)
	pass

func process_trouglovi(delta):
	var n = trouglovi.size()
	if n == 0: return
	for i in range(n):
		var trougao = trouglovi[i]
		trougao.position = Vector2.RIGHT.rotated(trouglovi_angle+i*TAU/n)*trouglovi_range
	
	trouglovi_duration_left -= delta
	trouglovi_angle = fmod(trouglovi_angle + 2*delta*(1.5 if n == 3 else 1) , TAU)
	if trouglovi_duration_left <= 0:
		for i in range(n):
			trouglovi[i].queue_free()
		trouglovi = []
		apply_cooldown(2,cooldowns[2]*2)

remote func sync_angle(angle):
	trouglovi_angle = angle

remotesync func second_ability(args):
	if get_tree().is_network_server():
		rpc("sync_angle",trouglovi_angle)
	create_trougao(args)
	apply_cooldown(2)
	set_mana(current_mana-mana_costs[2])

func create_trougao(args):
	if trouglovi.size() == 3: 
		trouglovi[2].queue_free()
		trouglovi.pop_back()
	var damage = Damage.new()
	damage.physical_damage = get_trougao_damage()
	var trougao = trougao_scene.instance()
	trougao.trougao_owner = self
	trougao.team = team
	trougao.name = args[ARGS.NAME]
	trougao.damage = damage
	trouglovi_node.add_child(trougao)
	trouglovi.append(trougao)
	trouglovi_duration_left = get_trougao_time()

func apply_confinement(players_in_range,confinement_position):
	for player_path in players_in_range:
		var player = get_node(player_path)
		var effect = Confinement.new()
		effect.duration = get_krug_duration()
		effect.confine_pos = confinement_position
		effect.confine_radius = 500
		effect.name = "KOSA_ARENA"
		effect.effect_owner = self
		player.rpc("apply_effect",inst2dict(effect))
		
remotesync func ultimate_ability(args):
	if get_tree().is_network_server():
		rpc("sync_angle",trouglovi_angle)
		var players_in_range_paths = []
		for player in Game.get_players_in_range(global_position,500,team,true):
			players_in_range_paths.append(get_path_to(player))
		apply_confinement(players_in_range_paths,global_position)
		var effect = Vamp.new()
		effect.duration = get_krug_duration()
		effect.vamp_amount = get_krug_life_steal()/100.0
		effect.name = "KOSA_VAMP"
		effect.effect_owner = self
		rpc("apply_effect",inst2dict(effect))
		effect = Haste.new()
		effect.duration = get_krug_duration()
		effect.haste_amount = get_krug_attack_speed()
		effect.name = "KOSA_HASTE"
		effect.effect_owner = self
		rpc("apply_effect",inst2dict(effect))
	var arena = arena_scene.instance()
	arena.kosa = self
	arena.global_position = global_position
	arena.duration = get_krug_duration()
	Game.get_visual_effects_node().add_child(arena)
	apply_cooldown(3)
	for i in 3:
		create_trougao(args)
	apply_cooldown(2)
	
