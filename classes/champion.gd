extends Entity
class_name Champion



signal mana_changed
signal level_up
signal item_set

export var base_mana : float
export var base_mana_regen : float

var mana : float
var mana_regen : float
var critical_chance : float
var cooldown_reduction : float

var additional_mana : float
var additional_mana_regen : float
var additional_critical_chance : float
var additional_cooldown_reduction : float

var level : int = 1
export var health_per_level : float
export var health_regen_per_level : float
export var mana_per_level : float
export var mana_regen_per_level : float
export var armor_per_level : float
export var magic_resist_per_level : float
export var attack_damage_per_level : float
export var attack_speed_per_level : float
export var cooldowns : Array = [0.0,0.0,0.0,0.0]
export var cooldown_decrease_per_level : Array = [0.0,0.0,0.0,0.0]
export var mana_costs : Array = [0.0,0.0,0.0,0.0]
export var mana_cost_increase_per_level : Array = [0.0,0.0,0.0,0.0]
var ability_levels : Array = [0.0,0.0,0.0,0.0]
var cooldown_timers : Array = [0.0,0.0,0.0,0.0]
var current_mana : float setget set_mana
var experience : float = 0.0
var experience_needed : float = 280
var ability_points : int = 1
var experience_costs_per_level : float = 100
var is_champion : bool = true
var champion_name : String
var player_name : String

var hud : HUD
var death_timer : Timer

export var first_ability_texture : Texture 
export var second_ability_texture : Texture 
export var ultimate_ability_texture : Texture

const item_attributes = ["movement_speed","health","armor","magic_resist",
"health_regen","attack_damage","attack_speed","ability_power","life_steal",
"tenacity","critical_chance","cooldown_reduction","mana","mana_regen"]

func get_exp_worth():
	return 100+sqrt(kill_streak)*50

remotesync func add_experience(amount):
	experience += amount
	if get_tree().is_network_server():
		while experience > experience_needed:
			rpc("level_up")

remotesync func apply_update(dict : Dictionary) -> void:
	Dicts.apply_update_to_champion(self,dict)

func apply_cooldown(ability, cooldown : float = -1):
	if cooldown == -1: cooldown_timers[ability] = cooldowns[ability]
	else: cooldown_timers[ability] = cooldown

func add_item(item : Item):
	for i in range(6):
		if items[i] == null:
			set_item(i,item)
			return true
	return false

func set_item(index : int, item : Item):
	items[index] = item
	update_stats()
	emit_signal("item_set",index,item)

func attempt_purchase(item : Item):
	rpc_id(1,"request_purchase",item.id)

remote func request_purchase(item_id : int):
	var item = Game.all_items[item_id]
	var cost = item.cost
	var p_components = items.duplicate()
	var removed = []
	for component_id in item.components:
		var component = Game.all_items[component_id]
		if component in p_components:
			var index = p_components.find(component)
			removed.append(index)
			p_components[index] = null
			cost -= component.cost
	if money >= cost and (null in items or removed != []):
		money -= cost
		for i in removed:
			rpc("remove_item",i)
		rpc("item_purchased",item_id,money)

remotesync func item_purchased(item_id,new_money):
	var item = Game.all_items[item_id]
	add_item(item)
	money = new_money

remote func sell_item(index):
	var item = items[index]
	if item != null:
		rpc("item_sold",index)
	
remotesync func item_sold(index):
	var item = items[index]
	money += item.cost*0.75
	remove_item(index)
	

remotesync func remove_item(index):
	set_item(index,null)

func reset_cooldown(ability):
	cooldown_timers[ability] = 0

func set_mana(value):
	current_mana = clamp(value,0,mana)
	emit_signal("mana_changed",current_mana)

func add_hud():
	hud = preload("res://menu/hud/hud.tscn").instance()
	add_child(hud)

func add_hpbar():
	hpbar = preload("res://champions/other/championhealthbar.tscn").instance()
	var color
	if int(name) == get_tree().get_network_unique_id(): color = Color(0.1,0.8,0.1)
	elif Lobby.my_team == team: color = Color(0.1,0.1,0.8)
	else: color = Color(0.8,0.1,0.1)
	hpbar.health_color = color
	add_child(hpbar)

func add_death_timer():
	death_timer = Timer.new()
	death_timer.one_shot = true
	death_timer.autostart = false
	death_timer.connect("timeout",self,"_server_respawn")
	add_child(death_timer)

func calculate_stats():
	mana = base_mana + additional_mana
	mana_regen = base_mana_regen + additional_mana_regen
	critical_chance = additional_critical_chance
	cooldown_reduction = additional_cooldown_reduction
	.calculate_stats()
	
func calculate_additional_stats():
	additional_mana = 0
	additional_mana_regen = 0
	additional_critical_chance = 0
	additional_cooldown_reduction = 0
	additional_health = 0
	additional_armor = 0
	additional_magic_resist = 0
	additional_health_regen = 0
	additional_attack_damage = 0
	additional_attack_speed = 0
	additional_attack_range = 0
	additional_ability_power = 0
	additional_movement_speed = 0
	additional_life_steal = 0
	additional_tenacity = 0

			
	for item in items:
		if item != null:
			for attribute in item_attributes:
				set("additional_"+attribute,get("additional_"+attribute) + item.get(attribute))
	for effect_name in effects:
		var effect = effects[effect_name]
		if effect is Haste: additional_attack_speed += effect.haste_amount
		elif effect is Torpor: additional_attack_speed -= effect.torpor_amount
		elif effect is Strength: additional_attack_damage += effect.strength_amount
		elif effect is Weakness: additional_attack_damage -= effect.weakness_amount
		elif effect is Slow: additional_movement_speed -= effect.slow_percentage * (base_movement_speed+additional_movement_speed)
		elif effect is Speed: additional_movement_speed += effect.speed_percentage * (base_movement_speed+additional_movement_speed)


func _ready():
	worth = 300
	exp_worth = 150
	current_mana = mana
	current_health = health
	if int(name) != get_tree().get_network_unique_id(): sprite.z_index = -1
	if is_network_master():
		add_hud()
		var camera = WorldCamera.new()
		camera.following = self
		camera.name = "WorldCamera"
		camera.current = true
		Game.camera = camera
		get_tree().current_scene.add_child(camera)
	add_hpbar()
	if get_tree().is_network_server():
		add_death_timer()
	Game.instantiate_player_icon(self)

func regulate_stats():
	.regulate_stats()
	set_mana(current_mana + mana_regen * STAT_TICK)

func _process(delta):
	current_mana = min(current_mana + mana_regen*delta,mana)
	if get_network_master() == get_tree().get_network_unique_id():
		_player_process(delta)
	if get_tree().is_network_server():
		_server_process(delta)
	for i in range(4):
		cooldown_timers[i] = move_toward(cooldown_timers[i],0,delta)
		
func _server_update_self():
	for player in Lobby.players:
		var t = Lobby.players[player][Lobby.INFO_TEAM]
		if t == self.team or revealed_to & (t+1) > 0:
			rpc_id(player,"apply_update",Dicts.champion_to_dict(self))

func level_up_ability(ability):
	rpc_id(1,"request_level_up",ability)

remote func request_level_up(ability):
	if can_level_up(ability):
		rpc("ability_leveled_up",ability)
	
remotesync func ability_leveled_up(ability):
	ability_levels[ability] += 1
	ability_points -= 1
	
func can_level_up(ability):
	if ability_points <= 0: return false
	if ability == 1 or ability == 2:
		return ability_levels[ability] < 8
	elif ability == 3:
		return ability_levels[3] < 4 and int(level)/5 > ability_levels[3]
		
func _server_process(delta):
	._server_process(delta)
	if Input.is_action_just_pressed("attack_move"):
		rpc("level_up")
	
remotesync func death(source_path):
	.death(source_path)
	var source = get_node(source_path)
	moveable -= 1
	castable -= 1
	able_to_basic -= 1
	dead = true
	visible = false
	ghosting += 1
	Optimizations.remove_entity(self)
	if get_tree().is_network_server():
		death_timer.start(10)
	if is_instance_valid(Game.hud):
		var text
		if is_network_master():
			text = "Porazeni ste."
			Game.hud.deathrect.visible = true
		else:
			match Lobby.my_team:
				-1: text = "Nastavnik je porazen!"
				team: text = "Prijateljski nastavnik je porazen."
				_: text = "Neprijateljski nastavnik je porazen!"
		Game.hud.add_announcement(text,source.sprite.texture,sprite.texture)
	

func _server_respawn():
	rpc("respawn")

remotesync func respawn():
	moveable += 1
	castable += 1
	able_to_basic += 1
	ghosting -= 1
	dead = false
	set_health(health)
	set_mana(mana)
	visible = true
	global_position = get_tree().current_scene.get_node("spawnpos%d" % team).global_position
	if is_network_master():
		Game.hud.deathrect.visible = false

func _player_process(delta):
	._player_process(delta)
	
remote func _server_set_path(destination):
	rpc("cancel_channeling")
	var path = Array(Game.get_navigation_path(global_position, destination))
	set_path(path)
	for player_id in Lobby.players:
		var t = Lobby.players[player_id][Lobby.INFO_TEAM]
		if team == t or revealed_to & (t+1) != 0:
			rpc_id(player_id,"set_path",path)

remote func _server_target_entity(target_path):
	rpc("target_entity",target_path)

func _server_basic_attack(args):
	._server_basic_attack(args)
	pass


remote func _server_cast_ability(ability,args):
	if cooldown_timers[ability] <= 0 and castable >= 1 and current_mana >= mana_costs[ability] and ability_levels[ability] > 0:
		rpc("cancel_channeling")
		args = Game.add_dictionaries(args,_server_get_args())
		var ability_func
		match ability:
			1: ability_func = "first_ability"
			2: ability_func = "second_ability"
			3: ability_func = "ultimate_ability"
		rpc(ability_func,args)

remote func _server_release_ability(ability,args):
	if cooldown_timers[ability] <= 0 and castable >= 1 and current_mana >= mana_costs[ability] and ability_levels[ability] > 0:
		rpc("cancel_channeling")
		args = Game.add_dictionaries(args,_server_get_args())
		var ability_func
		match ability:
			1: ability_func = "first_ability_release"
			2: ability_func = "second_ability_release"
			3: ability_func = "ultimate_ability_release"
		rpc(ability_func,args)

func _unhandled_input(event):
	if is_network_master():
		if Input.is_action_pressed("rmb") and movement_timer <= 0 and not Input.is_action_pressed("alt"):
			move_champion(get_global_mouse_position(),true)
		if Input.is_action_just_pressed("attack_move") and not Input.is_action_pressed("alt"):
			rpc_id(1,"_server_attack_nearest",get_global_mouse_position())
		if Input.is_action_just_pressed("stop_moving") and not Input.is_action_pressed("alt"):
			rpc_id(1,"_server_reset_path")
		if Input.is_action_just_released("rmb") and not Input.is_action_pressed("alt"):
			movement_timer = 0.0
		if Input.is_action_just_pressed("first_ability"):
			rpc_id(1,"_server_cast_ability",1,get_ability_args())
	#		rpc_id(1,"_server_first_ability",get_ability_args())
		if Input.is_action_just_pressed("second_ability"):
			rpc_id(1,"_server_cast_ability",2,get_ability_args())
	#		rpc_id(1,"_server_second_ability",get_ability_args())
		if Input.is_action_just_pressed("ultimate_ability"):
			rpc_id(1,"_server_cast_ability",3,get_ability_args())
		if Input.is_action_just_released("first_ability"):
			rpc_id(1,"_server_release_ability",1,get_ability_args())
		if Input.is_action_just_released("second_ability"):
			rpc_id(1,"_server_release_ability",2,get_ability_args())
		if Input.is_action_just_released("ultimate_ability"):
			rpc_id(1,"_server_release_ability",3,get_ability_args())
	#		rpc_id(1,"_server_ult_ability",get_ability_args())
func move_champion(destination,target_entities):
	if not is_instance_valid(Game.hovered_enemy) or not target_entities:
		rpc_id(1,"_server_set_path",destination)
		rpc_id(1,"_server_target_entity","none")
	elif target_entities:
		rpc_id(1,"_server_target_entity",get_path_to(Game.hovered_enemy))
	movement_timer = 0.2


remotesync func basic_attack(args):
	pass
remotesync func first_ability(args):
	pass
remotesync func second_ability(args):
	pass
remotesync func ultimate_ability(args):
	pass
remotesync func first_ability_release(args):
	pass
remotesync func second_ability_release(args):
	pass
remotesync func ultimate_ability_release(args):
	pass

remotesync func level_up():
	experience -= experience_needed
	experience_needed += experience_costs_per_level
	emit_signal("level_up")
	level += 1
	base_attack_damage += attack_damage_per_level
	base_attack_speed += attack_speed_per_level
	base_mana_regen += mana_regen_per_level
	base_health_regen += health_regen_per_level
	base_magic_resist += magic_resist_per_level
	base_armor += armor_per_level
	base_health += health_per_level
	base_mana += mana_per_level
	set_health(current_health + health_per_level)
	set_mana(current_mana + mana_per_level)
	ability_points += 1

func get_ability_args() -> Dictionary:
	var args = {}
	#args[ARGS.GPOS] = global_position
	args[ARGS.MPOS] = get_global_mouse_position()
	args[ARGS.TARGET_ENEMY_PATH] = ("none" if not is_instance_valid(Game.hovered_enemy) else get_path_to(Game.hovered_enemy) as String)
	args[ARGS.TARGET_ALLY_PATH] = ("none" if not is_instance_valid(Game.hovered_ally) else get_path_to(Game.hovered_ally) as String)
	return args
