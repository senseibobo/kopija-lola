extends Entity
class_name Minion

enum {
	CASTER,
	FIGHTER,
	BRUTE
}

var lane : int = 0
var movement_tick = 0.0
var general_path : PoolVector2Array
var current_path_point : int = 0
var damage : Damage = Damage.new()
var basic_scene = preload("res://world/turret/basic/turretbasic.tscn")
var hpbar_scene = preload("res://champions/other/minionhealthbar.tscn")
export var vision_range : float = 800.0

func _ready():
	base_health *= 1+Game.game_time/900
	update_stats()
	current_health = health
	collision_radius = 60.0
	set_as_toplevel(true)
	worth = 15
	var hpbar = hpbar_scene.instance()
	var color : Color
	hpbar.health_color = [Color(0.8,0.1,0.1),Color(0.1,0.1,0.8)][int(Lobby.my_team == team)]
	add_child(hpbar)
	#Game.minimap_minions.append(self)
	Game.instantiate_minion_icon(self)

remotesync func basic_attack(args):
	var t = get_node_or_null(args[ARGS.TARGET_ENEMY_PATH])
	if not is_instance_valid(t): return
	damage.physical_damage = attack_damage
	var proj = basic_scene.instance()
	proj.projectile_owner = self
	proj.target = t
	proj.global_position = args[ARGS.GPOS]
	proj.damage = damage
	proj.name = args[ARGS.NAME]
	proj.team = team
	proj.speed *= 1.2
	proj.scale *= 0.4
	Game.get_projectile_node().add_child(proj)

remotesync func update_path_point(new_path_point):
	current_path_point = new_path_point

func _server_process(delta):
	._server_process(delta)
	movement_tick = move_toward(movement_tick,0,delta)
	if movement_tick <= 0:
		if current_path_point < general_path.size() and global_position.distance_squared_to(general_path[current_path_point]) < 1000000:
			current_path_point += 1
			rpc("update_path_point",current_path_point)
		if not is_instance_valid(target) or target.dead:
			var entities_in_range = Game.get_entities_in_range(global_position,vision_range,team,true,true)
			if entities_in_range != []:
				rpc("target_entity",get_path_to(entities_in_range[0]))
			elif current_path_point < general_path.size():
				rpc("set_path",Game.get_navigation_path(global_position,general_path[current_path_point]))
		else:
			if global_position.distance_squared_to(target.global_position) < vision_range * 1.2 * vision_range * 1.2:
				rpc("target_entity","none")
		movement_tick = 1
