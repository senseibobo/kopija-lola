extends Node2D

enum ARGS {
	NAME,
	LANE,
	GPOS,
	PATH
}

var revelation_lines = []
var revealed := []
var raycast : RayCast2D
var minion_timer : float = 25#20
var minion_cooldown : float = 35#25 
const MINION_TICK : float = 0.6

var minion_spawn_positions : Dictionary = {
	0: {
		"top": Vector2(),
		"mid": Vector2(250,4750),
		"bot": Vector2()
	},
	1: {
		"top": Vector2(),
		"mid": Vector2(4750,250),
		"bot": Vector2()
	}
}

const SERVER_TICK_TIME : float = 0.3

func _ready():
	for i in $Polygons.get_children():
		var occluder = LightOccluder2D.new()
		var occpoly = OccluderPolygon2D.new()
		occpoly.polygon = i.polygon
		occpoly.cull_mode = occpoly.CULL_CLOCKWISE
		occluder.occluder = occpoly
		$Polygons.add_child(occluder)
		var staticbody = StaticBody2D.new()
		var collisionpolygon = CollisionPolygon2D.new()
		collisionpolygon.polygon = i.polygon
		$Polygons.add_child(staticbody)
		staticbody.add_child(collisionpolygon)

	if get_tree().is_network_server():
		var camera = WorldCamera.new()
		camera.unlocked = true
		camera.current = true
		camera.global_position = Vector2(250,4750)
		camera.name = "WorldCamera"
		Game.camera = camera
		add_child(camera)
		raycast = RayCast2D.new()
		raycast.collide_with_areas = true
		add_child(raycast)
		var timer = Timer.new()
		timer.autostart = false
		timer.one_shot = false
		add_child(timer)
		timer.start(SERVER_TICK_TIME)
		timer.connect("timeout",self,"_server_tick")

func _server_tick():
	check_revelation()
	update_players()
	regulate_minions()

func regulate_minions():
	minion_timer += SERVER_TICK_TIME
	if minion_timer > minion_cooldown:
		minion_timer = 0
		spawn_minions()

func spawn_minions():
	for type in [Minion.FIGHTER,Minion.CASTER]:
		for i in range(3):
			for team in range(2):
				for lane in ["top","bot"]:
					var args = {}
					args[ARGS.NAME] = str(Game.current_number)
					args[ARGS.LANE] = lane
					var spawnposnode = get_node("MinionManagement/spawn%s%d" % [lane,team])
					args[ARGS.GPOS] = spawnposnode.global_position
					args[ARGS.PATH] = get_node("MinionManagement/%s%d"%[lane,team]).points
					rpc("instantiate_minion",team,type,args)
			yield(get_tree().create_timer(MINION_TICK),"timeout")

remotesync func instantiate_minion(team : int, type : int, args : Dictionary):
	var minion_node = Game.get_minion_node()
	var lane = args[ARGS.LANE]
	var minion : Minion
	match type:
		Minion.CASTER : minion = preload("res://minions/caster.tscn").instance()
		Minion.FIGHTER : minion = preload("res://minions/fighter.tscn").instance()
		Minion.BRUTE : pass
	minion.global_position = args[ARGS.GPOS]
	minion.name = args[ARGS.NAME]
	minion.team = team
	minion.general_path = args[ARGS.PATH]
	Game.get_minion_node().add_child(minion)
	if get_tree().is_network_server():
		var effect = Ghosting.new()
		effect.duration = 10.0
		effect.name = "MINION_SPAWN_GHOSTING"
		minion.rpc("apply_effect",inst2dict(effect))

func update_players():
	for entity in Game.get_entities():
		entity._server_update_self()

func check_revelation():
	var update = false
	revelation_lines = []
	for team in range(3):
		raycast.collision_mask = 49
		raycast.set_collision_mask_bit(4+team,true)
		for entity in Game.get_entities(team):
			var entity_revealed_to = 0
			for light in Optimizations.get_entities_around_cell(entity.grid_coords,team,true,Optimizations.get_min_cell_radius(1000)):
				if not is_instance_valid(entity) or entity.dead or light.dead: continue
				raycast.set_collision_mask_bit(5-light.team,false)
				raycast.global_position = light.global_position
				raycast.cast_to = entity.global_position - raycast.global_position
				var rev_line = [raycast.global_position,raycast.global_position + raycast.cast_to]
				revelation_lines.append(rev_line)
				raycast.force_raycast_update()
				if not raycast.is_colliding() and raycast.cast_to.length() < 1024:
					entity_revealed_to = entity_revealed_to | (light.team+1)
					continue
			if entity.revealed_to != entity_revealed_to:
				update = true
				entity.revealed_to = entity_revealed_to
#	if update:
#		for team in range(2):
	var update_dict = {}
	for entity in Game.get_entities():
		update_dict[get_path_to(entity)] = [entity.global_position,entity.path,entity.revealed_to]
	for player in Lobby.players:
		#if Lobby.players[player][Lobby.INFO_TEAM] != team:
		rpc_id(player,"update_revealed",update_dict)
	update()

remote func update_revealed(new_revealed):
	var entities = Game.get_entities(Lobby.my_team,true)
	var new_revealed_inst = []
	for path_to_entity in new_revealed: 
		new_revealed_inst.append(get_node(path_to_entity))
	for entity in entities:
		var path_to_entity = get_path_to(entity)
		if not path_to_entity in new_revealed: continue
		if not entity.dead and entity in new_revealed_inst:
			entity.global_position = new_revealed[path_to_entity][0]
			entity.set_path(new_revealed[path_to_entity][1])
		entity.revealed_to = new_revealed[path_to_entity][2]
		entity.visible = (Lobby.my_team == -1 or entity.revealed_to & (Lobby.my_team+1) != 0) 

func _draw():
	for line in revelation_lines:
		draw_line(line[0],line[1],Color.red,2.0)
