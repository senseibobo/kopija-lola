extends Entity
class_name Pet

var pet_owner

func _unhandled_input(event):
	if Input.is_action_pressed("alt") and is_network_master():
		if Input.is_action_just_pressed("rmb") and movement_timer <= 0:
			move_pet(get_global_mouse_position(),true)
		if Input.is_action_just_released("rmb"):
			movement_timer = 0.0
		if Input.is_action_just_pressed("attack_move"):
			rpc_id(1,"_server_attack_nearest",get_global_mouse_position())
		if Input.is_action_just_pressed("stop_moving"):
			move_pet(global_position,false)

func move_pet(destination,target_entities):
	if not is_instance_valid(Game.hovered_enemy) or not target_entities:
		rpc_id(1,"_server_set_path",destination)
		rpc_id(1,"_server_target_entity","none")
	elif target_entities:
		rpc_id(1,"_server_target_entity",get_path_to(Game.hovered_enemy))
	movement_timer = 0.2

remote func _server_set_path(destination):
	rpc("set_path",Game.get_navigation_path(global_position,destination))
remote func _server_target_entity(entity_path):
	rpc("target_entity",entity_path)
remote func _server_attack_nearest(pos):	
	var entities = Game.get_entities_in_range(pos,attack_range,team,true,true)
	if entities != []:
		rpc("target_entity",get_path_to(entities[0]))
	else:
		rpc("set_path",Game.get_navigation_path(global_position,pos))
	rpc("target_entity")



func copy_stats(p):
	base_armor = p.armor
	base_movement_speed = p.movement_speed
	base_attack_range = p.attack_range
	base_attack_speed = p.attack_speed
	base_health = p.health
	base_magic_resist = p.magic_resist
