extends Objective
class_name Turret

var basic_scene = preload("res://world/turret/basic/turretbasic.tscn")

onready var shootpos = get_node("ShootPos").position


var damage : Damage = Damage.new()
var player_damage_multiplier : float = 1.0
onready var laser : Line2D = $Line2D

remotesync func basic_attack(args):
	if not is_instance_valid(target): return
	damage.physical_damage = attack_damage * player_damage_multiplier
	var proj = basic_scene.instance()
	player_damage_multiplier = move_toward(player_damage_multiplier,2.5,0.4)
	proj.projectile_owner = self
	proj.target = get_node(args[ARGS.TARGET_ENEMY_PATH])
	proj.global_position = args[ARGS.GPOS] + shootpos
	proj.damage = damage
	proj.name = args[ARGS.NAME]
	proj.team = team
	Game.get_projectile_node().add_child(proj)
	
remotesync func apply_effect(effect_dict):
	pass

func _ready():
	hpbar.health_color = [Color(0.8,0.1,0.1),Color(0.1,0.1,0.8)][int(Lobby.my_team == team)]
	Game.minimap_turrets.append(self)


func _server_process(delta):
	._server_process(delta)
	var old_target = target
	if not is_instance_valid(target) or target.dead or not Game.is_entity_in_range(target,global_position,attack_range):
		choose_target()
	
	if old_target != target:
		var target_path = ("none" if not is_instance_valid(target) else get_path_to(target))
		rpc("target_entity",target_path)
	if is_instance_valid(target) and global_position.distance_squared_to(target.global_position) < attack_range*attack_range:
		if not is_channeling and ((target.revealed_to & (team+1)) != 0 or target.omnivisible):
			var args = {}
			args[ARGS.GPOS] = global_position
			args[ARGS.TARGET_ENEMY_PATH] = get_path_to(target)
			_server_basic_attack(args)

remotesync func reset_pdm():
	player_damage_multiplier = 1

func _process(delta):
	if is_instance_valid(target):
		laser.points = PoolVector2Array([$ShootPos.position,target.global_position-global_position])
	else:
		laser.points = PoolVector2Array([])
		

func choose_target():
	target = null
	var old_pdm = player_damage_multiplier
	player_damage_multiplier = 1
	var pentities = Game.get_pentities_in_range(global_position,attack_range,team,true)
	var minions = Game.get_minions_in_range(global_position,attack_range,team,true)
	var players = Game.get_players_in_range(global_position,attack_range,team,true)
	if pentities != []: target = pentities[0]
	elif minions != []: target = minions[0]
	elif players != []:
		target = players[0]
		player_damage_multiplier = old_pdm

	if player_damage_multiplier != old_pdm:
		rpc("reset_pdm")
