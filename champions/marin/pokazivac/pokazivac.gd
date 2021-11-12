extends Entity

var timer : Timer
var basic_damage : Damage
var hex_damage : Damage

var times_attacked : int = 0
var attack_ready : bool = false
var pokazivac_owner : Entity
onready var char_attack_scene = preload("res://champions/marin/pokazivac/char/marincharattack.tscn")
onready var hex_attack_scene = preload("res://champions/marin/pokazivac/hex/marinhexattack.tscn")

func _ready():
	hpbar = preload("res://champions/other/minionhealthbar.tscn").instance()
	hpbar.health_color = [Color(0.8,0.1,0.1),Color(0.1,0.1,0.8)][int(Lobby.my_team == team)]
	add_child(hpbar)

func _server_process(delta):
	._server_process(delta)
	var old_target = target
	var new_target = null
	var targets = Game.sort_by_distance(global_position,Optimizations.get_entities_around_cell(grid_coords,team,true,1))
	for t in targets:
		if not t.global_position.distance_squared_to(global_position) < attack_range*attack_range: continue
		if not t.targetable_by_pentities: continue
		new_target = t
		break
	target = new_target
	if is_instance_valid(target) and target != old_target:
		rpc("target_entity",get_path_to(target))

remotesync func basic_attack(args):
	if not is_instance_valid(target): return
	if get_tree().is_network_server():
		if times_attacked >= 5:
			rpc("explode",args)
		else:
			rpc("shoot",args)
		
remotesync func shoot(args):
	var proj = char_attack_scene.instance()
	proj.projectile_owner = pokazivac_owner
	proj.team = team
	proj.target = get_node(args[ARGS.TARGET_ENEMY_PATH])
	proj.damage = basic_damage
	proj.name = args[ARGS.NAME] + "_basic"
	proj.global_position = args[ARGS.GPOS]
	Game.get_projectile_node().add_child(proj)
	times_attacked += 1

remotesync func explode(args):
	death(null)
	for i in range(8):
		var proj = hex_attack_scene.instance()
		proj.projectile_owner = pokazivac_owner
		proj.team = team
		proj.damage = hex_damage
		proj.name = args[ARGS.NAME]+"_explode_"+str(i)
		proj.direction = Vector2.RIGHT.rotated(i*TAU/8)
		proj.global_position = global_position
		Game.get_projectile_node().add_child(proj)
