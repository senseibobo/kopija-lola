extends Node2D
class_name Entity

enum ARGS {
	GPOS,
	MPOS,
	TARGET_ENEMY_PATH,
	TARGET_ALLY_PATH,
	RANDOM,
	NAME,
	HEALTH,
	CURRENT_HEALTH,
	MANA,
	CURRENT_MANA,
	ARMOR,
	MAGIC_RESIST,
	HEALTH_REGEN,
	ATTACK_DAMAGE,
	ATTACK_SPEED,
	REVEALED_TO,
	PATH,
	LEVEL,
	DEAD
}

signal health_changed
signal speed_changed
signal killed_entity
signal death
signal taken_damage
signal healed_damage
signal shield_changed
signal cripple_changed
signal on_path_set
signal channel_started
signal channel_cancelled
signal channel_finished


export var base_movement_speed : float 
export var base_health : float
export var base_armor : float
export var base_magic_resist : float
export var base_health_regen : float
export var base_attack_damage : float
export var base_attack_speed : float
export var base_attack_range : float

var additional_movement_speed : float 
var additional_health : float
var additional_armor : float
var additional_magic_resist : float
var additional_health_regen : float
var additional_attack_damage : float
var additional_attack_speed : float
var additional_attack_range : float
var additional_ability_power : float
var additional_life_steal : float
var additional_tenacity : float

var movement_speed : float 
var health : float
var armor : float
var magic_resist : float
var health_regen : float
var attack_damage : float
var attack_speed : float
var attack_range : float
var ability_power : float
var life_steal : float
var tenacity : float



export var omnivisible : bool = false
export var exp_worth : float = 20
export var targetable_by_pentities : bool = true
export var locked_in_place : bool = false
export var collision_radius : float = 0.0
export var gameplay_radius : float = 32.0
export var select_radius : float = 100
var path : Array
export var team : int
var current_health : float setget set_health
var sprite : Sprite
var basic_attack_timer : Timer
var basic_attack_ready : bool = true
var last_channeled : String = ""
var is_channeling : bool = false
var channeling_name : String = ""
var channeling_duration : float = 0.0
var channeling_timer : float = 0.0
var last_channeling_timer : float = 0.0
var channeling_tween : Tween
var hpbar : Healthbar
var creep_score : int = 0
var money : float = 500
var money_gain : float = 1.7
var dead : bool = false
var worth : int
var creep_score_worth : int = 0
var target : Node2D
var movement_timer : float = 0.0
var moveable : int = 1
var castable : int = 1
var able_to_basic : int = 1
var targetable : int = 1
var revealed_to : int = 0
var shield : float = 0.0
var ghosting : int = 0
var cripple : float = 0.0
var effects : Dictionary
var items : Array = [null,null,null,null,null,null]
var dir : Vector2
var grid_coords : Vector2
var kills : int = 0
var deaths : int = 0
var assists : int = 0
var kill_streak : int = 0
var damagers : Array = []


var attack_windup : float = 0.16


const STAT_TICK : float = 2.0


#debug
const icon = preload("res://icon.png")


func get_exp_worth():
	return exp_worth

func regulate_shields_cripples():
	for effect in effects:
		if effects[effect] is Shield and effects[effect].shield_amount <= 0:
			remove_effect(effect)
		elif effects[effect] is Cripple and effects[effect].cripple_amount <= 0:
			remove_effect(effect)


remote func request_effect(effect_name):
	var effect = get_effect(effect_name)
	if effect == null:
		return
	else:
		rpc_id(get_tree().get_rpc_sender_id(),"apply_effect",inst2dict(get_effect(effect_name)))

func remove_health(value):
	for effect in effects:
		if value <= 0: break
		if effects[effect] is Shield:
			var mitigated = clamp(value,0,effects[effect].shield_amount)
			effects[effect].shield_amount -= mitigated
			value -= mitigated
			if effects[effect].shield_amount <= 0:
				remove_effect(effect)
	update_shield()
	if value > 0:
		set_health(current_health - value)


func add_health(value):
	for effect in effects:
		if value <= 0: break
		if effects[effect] is Cripple:
			var mitigated = clamp(value,0,effects[effect].cripple_amount)
			effects[effect].cripple_amount -= mitigated
			value -= mitigated
			if effects[effect].cripple_amount <= 0:
				remove_effect(effect)
	update_cripple()
	if value > 0:
		emit_signal("healed_damage")
		set_health(current_health + value)
		if visible and value > 0:
			var heal = Damage.new()
			heal.heal = value
			Numbers.add_number(str(heal),Color.green,global_position,Vector2(1,1))

func set_health(value):
	current_health = clamp(value,0,health)
	emit_signal("health_changed",current_health)

func killed_entity(entity):
	add_creep_score(entity.creep_score_worth)
	add_money(entity.worth)
	add_kill()
		
func add_kill():
	kill_streak += 1
	kills += 1

remotesync func add_creep_score(amount):
	creep_score += amount



func has_effect(effect_name : String):
	for effect in effects:
		if effect == effect_name: return true
	return false

func get_effect(effect_name : String):
	for effect in effects:
		if effect == effect_name: return effects[effect]
	return null

func get_effect_meta(meta_name : String):
	for effect in effects:
		if effects[effect].has_meta(meta_name): return effects[effect]
	return null

func add_shield(value):
	set_shield(shield + value)

func remove_shield(value):
	set_shield(shield - value)

func set_shield(value):
	var old_shield = shield
	shield = value
	if shield != old_shield:
		emit_signal("shield_changed",shield)
	update_shield()

func update_shield():
	var old_shield = shield
	var new_shield = 0.0
	for effect in effects:
		if effects[effect] is Shield:
			new_shield += effects[effect].shield_amount
	shield = new_shield
	if old_shield != new_shield:
		emit_signal("shield_changed",shield)

func update_cripple():
	var old_cripple = cripple
	var new_cripple = 0.0
	for effect in effects:
		if effects[effect] is Cripple:
			new_cripple += effects[effect].cripple_amount
	cripple = new_cripple
	if old_cripple != new_cripple:
		emit_signal("cripple_changed",cripple)

func add_cripple(value):
	set_cripple(cripple + value)

func remove_cripple(value):
	set_cripple(cripple - value)

func set_cripple(value):
	var old_cripple = cripple
	cripple = value
	if cripple != old_cripple:
		emit_signal("cripple_changed",cripple)
	update_cripple()

remotesync func remove_effect(effect_name : String):
	var effect = get_effect(effect_name)
	if effect != null:
		effect.expire()
		effects.erase(effect_name)
		
remotesync func apply_effect(effect_dict):
	var effect = dict2inst(effect_dict)
	remove_effect(effect.name)
	effects[effect.name] = effect
	effect.p = self
	effect.apply()
	
func regulate_stats():
	set_health(current_health + health_regen * STAT_TICK)

func _ready():
	if Lobby.my_team == team:
		add_light()
	elif not get_tree().is_network_server() and not omnivisible:
		visible = false
	add_channeling_tween()
	init_timers()
	connect("killed_entity",self,"killed_entity")
	add_basic_attack_timer()
	init_stats()
	init_outline()
	calculate_grid_coords()

func calculate_grid_coords():
	var old_coords = grid_coords
	grid_coords.x = floor(global_position.x/Optimizations.CELL_SIZE)
	grid_coords.y = floor(global_position.y/Optimizations.CELL_SIZE)
	if old_coords != grid_coords:
		Optimizations.update_entity(self,grid_coords)

func calculate_additional_stats():
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
	for effect_name in effects:
		var effect = effects[effect_name]
		if effect is Haste: additional_attack_speed += effect.haste_amount
		elif effect is Torpor: additional_attack_speed -= effect.torpor_amount
		elif effect is Strength: additional_attack_damage += effect.strength_amount
		elif effect is Weakness: additional_attack_damage -= effect.weakness_amount
		elif effect is Slow: additional_movement_speed -= effect.slow_percentage * (base_movement_speed+additional_movement_speed)
		elif effect is Speed: additional_movement_speed += effect.speed_percentage * (base_movement_speed+additional_movement_speed)
			

func calculate_stats():
	health = base_health + additional_health
	armor = base_armor + additional_armor
	magic_resist = base_magic_resist + additional_magic_resist
	health_regen = base_health_regen + additional_health_regen
	attack_damage = base_attack_damage + additional_attack_damage
	attack_speed = base_attack_speed * (1+additional_attack_speed)
	attack_range = base_attack_range + additional_attack_range
	ability_power = additional_ability_power
	movement_speed = base_movement_speed + additional_movement_speed
	life_steal = additional_life_steal
	tenacity = additional_tenacity

func update_stats():
	calculate_additional_stats()
	calculate_stats()
	

func init_stats():
	calculate_stats()
	current_health = health

func init_outline():
	sprite = get_node_or_null("Sprite") as Sprite
	if is_instance_valid(sprite):
		sprite.material = ShaderMaterial.new() as ShaderMaterial
		sprite.material.shader = preload("res://shaders/outline.gdshader")
		sprite.material.set_shader_param("outline_width",0.0)
		if get_network_master() == get_tree().get_network_unique_id(): 
			sprite.material.set_shader_param("outline_color",Color(0.2,0.9,0.2))
		elif team == Lobby.my_team: 
			sprite.material.set_shader_param("outline_color",Color(0.2,0.2,0.9))
		else: 
			sprite.material.set_shader_param("outline_color",Color(0.9,0.2,0.2))

func init_timers():
	add_stat_timer()
	add_basic_attack_timer()

func add_channeling_tween():
	channeling_tween = Tween.new()
	add_child(channeling_tween)

func add_light():
	var light
	light = preload("res://champions/other/light.tscn").instance()
	light.texture_scale = 0
	add_child(light)
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(light,"texture_scale",0,1,0.5)
	tween.connect("tween_all_completed",tween,"queue_free")
	tween.start()

func add_stat_timer():
	var stat_timer = Timer.new()
	stat_timer.one_shot = false
	stat_timer.autostart = false
	add_child(stat_timer)
	stat_timer.start(STAT_TICK)
	stat_timer.connect("timeout",self,"update_stats")

func add_basic_attack_timer():
	basic_attack_timer = Timer.new()
	basic_attack_timer.one_shot = true
	basic_attack_timer.autostart = false
	basic_attack_timer.connect("timeout",self,"set_basic_attack_ready") 
	add_child(basic_attack_timer)

remote func apply_update(dict):
	Dicts.apply_update_to_entity(self,dict)

func _server_update_self():
	for player in Lobby.players:
		if Lobby.players[player][Lobby.INFO_TEAM] == self.team or self.revealed_to != 0:
			rpc_id(player,"apply_update",Dicts.entity_to_dict(self))

	
func set_basic_attack_ready():
	basic_attack_ready = true

func check_hover(delta):
	if targetable <= 0: return
	var dist = get_global_mouse_position().distance_squared_to(global_position)
	var s = select_radius*select_radius
	if dist < s:
		var dist_to_ally = s if not is_instance_valid(Game.hovered_ally) else get_global_mouse_position().distance_squared_to(Game.hovered_ally.global_position)
		var dist_to_enemy = s if not is_instance_valid(Game.hovered_enemy) else get_global_mouse_position().distance_squared_to(Game.hovered_enemy.global_position)
		if team == Lobby.my_team and dist_to_ally > dist:
			Game.hovered_ally = self
			var outline_size = lerp(sprite.material.get("shader_param/outline_width"),3.0,20*delta)
			sprite.material.set("shader_param/outline_width",outline_size)
		elif team != Lobby.my_team and dist_to_enemy > dist:
			Game.hovered_enemy = self
			var outline_size = lerp(sprite.material.get("shader_param/outline_width"),3.0,20*delta)
			sprite.material.set("shader_param/outline_width",outline_size)
	else:
		if Game.hovered_ally == self:
			Game.hovered_ally = null
		elif Game.hovered_enemy == self:
			Game.hovered_enemy = null
		else:
			var outline_size = lerp(sprite.material.get("shader_param/outline_width"),0,20*delta)
			sprite.material.set("shader_param/outline_width",outline_size)


remotesync func death(source_path):
	var source = get_node_or_null(source_path) if source_path != null else null
	if self == Game.hovered_enemy: Game.hovered_enemy = null
	if self == Game.hovered_ally: Game.hovered_ally = null
	if is_instance_valid(source): 
		source.emit_signal("killed_entity",self)
		if get_tree().is_network_server():
			var players_in_range = Game.get_players_in_range(global_position,1000,team,true)
			var size = players_in_range.size()
			for player in players_in_range:
				player.rpc("add_experience",get_exp_worth()/lerp(size,1,0.75))
	for effect in effects:
		if not effects[effect].persistent:
			remove_effect(effect)
	emit_signal("death")
	Optimizations.remove_entity(self)
	if not "is_champion" in self:
		queue_free()
	pass

remotesync func add_money(amount : int):
	money += amount
	if is_network_master():
		Numbers.add_number("+%dg" % amount,Color.goldenrod,global_position,Vector2(1,1))

func take_damage(damage_dict, source_path):
	var damage = Dicts.damage_from_dict(damage_dict)
	var source = null
	if source_path != null:
		source = get_node_or_null(source_path)
	if armor >= 0: damage.physical_damage = damage.physical_damage*(100.0/(100.0+armor))
	else: damage.physical_damage = damage.physical_damage*(2.0-100.0/(100.0-armor))
	
	if magic_resist >= 0: damage.magic_damage = damage.magic_damage*(100.0/(100.0+magic_resist))
	else: damage.magic_damage = damage.magic_damage*(2.0-100.0/(100.0-magic_resist))
	
	damage.physical_damage *= 1.0+damage.crit_percent
	damage.magic_damage *= 1.0+damage.crit_percent
	
	var s
	if damage.physical_damage > 0:
		s = pow(clamp(damage.physical_damage,10,1000)/100.0,1/3)
		Numbers.add_number(str(damage.physical_damage),Color.red,global_position,Vector2(1,1))
	if damage.magic_damage > 0:
		s = pow(clamp(damage.magic_damage,10,1000)/100.0,1/3)
		Numbers.add_number(str(damage.magic_damage),Color.cornflower,global_position,Vector2(1,1))
	if damage.true_damage > 0:
		s = pow(clamp(damage.true_damage,10,1000)/100.0,1/3)
		Numbers.add_number(str(damage.true_damage),Color.white,global_position,Vector2(1,1))
	if damage.pure_damage > 0:
		s = pow(clamp(damage.pure_damage,10,1000)/100.0,1/3)
		Numbers.add_number(str(damage.pure_damage),Color.aqua,global_position,Vector2(1,1))
	
	var total_damage : float = 0.0
	total_damage += damage.physical_damage
	total_damage += damage.magic_damage
	total_damage += damage.true_damage
	total_damage += damage.pure_damage
	if total_damage > 0:
		var dmg = [damage.physical_damage,damage.magic_damage,damage.true_damage,damage.pure_damage]
		rpc("issue_damage",dmg,null if not is_instance_valid(source) else get_path_to(source))
		damagers.append([source,10.0])
		emit_signal("taken_damage",total_damage,source)
	if is_instance_valid(source):
		source.add_health(damage.physical_damage*source.life_steal)
	#set_health(current_health - total_damage)
	


remotesync func issue_damage(dmg,source_path):
	var total_damage : float = 0.0
	total_damage += dmg[0]
	total_damage += dmg[1]
	total_damage += dmg[2]
	total_damage += dmg[3]
	remove_health(total_damage)
	if get_tree().is_network_server() and current_health <= 0 and not dead:
		rpc("death",source_path)
	var s
	var colors = [Color.red,Color.cornflower,Color.white,Color.aqua]
	for i in range(dmg.size()):
		if dmg[i] > 0:
			s = sqrt(clamp(dmg[i],10,1000)/100.0)
			Numbers.add_number(str(dmg[i]),colors[i],global_position,s*Vector2(1,1))
		
#	if dmg[0] > 0:
#		s = sqrt(clamp(dmg[0],10,1000)/100.0)
#		Numbers.add_number(str(dmg[0]),Color.red,global_position,s*Vector2(1,1))
#	if dmg[1] > 0:
#		s = sqrt(clamp(dmg[1],10,1000)/100.0)
#		Numbers.add_number(str(dmg[1]),Color.cornflower,global_position,s*Vector2(1,1))
#	if dmg[2] > 0:
#		s = sqrt(clamp(dmg[2],10,1000)/100.0)
#		Numbers.add_number(str(dmg[2]),Color.white,global_position,s*Vector2(1,1))
#	if dmg[3] > 0:
#		s = sqrt(clamp(dmg[3],10,1000)/100.0)
#		Numbers.add_number(str(dmg[3]),Color.aqua,global_position,s*Vector2(1,1))
#

func _effect_process(delta):
	for effect in effects:
		effects[effect]._process(delta)

remote func _server_attack_nearest(point : Vector2):
	var entities = Game.get_entities_in_range(point,attack_range,team,true,true)
	if entities != []:
		rpc("target_entity",get_path_to(entities[0]))
	else:
		rpc("set_path",Game.get_navigation_path(global_position,point))
	


func _process(delta):
	_effect_process(delta)
	calculate_grid_coords()
	money += money_gain*delta + 1.3*Game.game_time/1080.0
	current_health = min(current_health+health_regen*delta,health)
	if is_channeling:
		channeling_timer = move_toward(channeling_timer,channeling_duration,delta)
		last_channeling_timer = channeling_timer
		if channeling_timer >= channeling_duration:
			finish_channeling()
	for damager in damagers:
		damager[1] -= delta
		if damager[1] <= 0:
			damagers.erase(damager)
	if visible:
		check_hover(delta)
		movement_timer = move_toward(movement_timer,0,delta)
		if get_network_master() == get_tree().get_network_unique_id():
			_player_process(delta)
		if get_tree().is_network_server():
			_server_process(delta)
		if path != [] and not locked_in_place:
			if moveable >= 1 and not is_channeling:
				var old_pos = global_position
				global_position = global_position.move_toward(path[0],movement_speed*delta)
				if global_position.distance_squared_to(path[0]) <= 4.0:
					path.pop_front()
				if not Rect2(0,0,4999,4999).has_point(global_position):
					global_position = old_pos
				Optimizations.collision_slide(self)
			else:
				path = []

func _player_process(delta):
	if is_instance_valid(target):
		if global_position.distance_squared_to(target.global_position) < attack_range*attack_range:
			path = []

func _server_process(delta):
	if is_instance_valid(target):
		if target.dead or (not target.revealed_to & (team+1) != 0 and not target.omnivisible): 
			rpc("target_entity","none")
		else:
			if movement_timer <= 0 and global_position.distance_squared_to(target.global_position) > attack_range*attack_range:
				rpc("set_path",Game.get_navigation_path(global_position,target.global_position))
				movement_timer = 0.2
			if global_position.distance_squared_to(target.global_position) < attack_range*attack_range:
				path = []
				if not is_channeling and (target.revealed_to & (team+1) != 0 or target.omnivisible):
					var args = {}
					args[ARGS.GPOS] = global_position
					args[ARGS.TARGET_ENEMY_PATH] = get_path_to(target)
					_server_basic_attack(args)
	else:
		rpc("target_entity","none")

func _server_basic_attack(args):
	if able_to_basic >= 1 and basic_attack_ready:
		args = Game.add_dictionaries(args,_server_get_args())
		args[ARGS.GPOS] = global_position
		rpc("channel_basic_attack",args)

remote func _server_reset_path():
	rpc("set_path",[])
		
remotesync func channel_basic_attack(args):
	start_channeling("Basic",attack_windup/attack_speed,Color.red)
	yield(self,"channel_finished")
	basic_attack_timer.start((1-attack_windup)/attack_speed)
	basic_attack_ready = false
	if get_tree().is_network_server():# and is_instance_valid(get_node_or_null(args[ARGS.TARGET_ENEMY_PATH])):
		args[ARGS.GPOS] = global_position
		args[ARGS.TARGET_ENEMY_PATH] = get_path_to(target)
		rpc("basic_attack",args)
	set_path([])

remotesync func set_path(new_path):
	set_deferred("path",new_path)
	emit_signal("on_path_set",new_path)
	
remotesync func start_channeling(cname,channeling_duration,sprite_color,priority : bool = false):
	if is_channeling: 
		if priority:
			cancel_channeling()
		else:
			return
	is_channeling = true
	channeling_name = cname
	self.channeling_duration = channeling_duration
	channeling_tween.interpolate_property(sprite,"modulate",Color.white,sprite_color,channeling_duration)
	channeling_tween.start()
	emit_signal("channel_started",channeling_name)

remotesync func cancel_channeling():
	stop_channeling()
	emit_signal("channel_cancelled",channeling_name)

remotesync func stop_channeling():
	if not is_channeling: return
	last_channeled = channeling_name
	is_channeling = false
	channeling_name = ""
	channeling_timer = 0.0
	channeling_tween.stop_all()
	sprite.modulate = Color.white
	

remotesync func finish_channeling():
	stop_channeling()
	emit_signal("channel_finished",last_channeled)

remotesync func target_entity(target_path):
	target = get_node_or_null(target_path)
	if not is_instance_valid(target) or target.dead: target = null
	
func _server_get_args():
	var args = {}
	args[ARGS.GPOS] = global_position
	args[ARGS.RANDOM] = rand_range(0,1000)
	args[ARGS.NAME] = str(Game.current_number)
	return args
	
remotesync func basic_attack(args):
	pass
