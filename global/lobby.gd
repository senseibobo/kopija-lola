extends Node

enum {
	INFO_NAME,
	INFO_CHAMPION,
	INFO_TEAM,
	INFO_INDEX
	INFO_LOCKED_IN
}

signal game_finished
signal player_locked_in
signal player_registered
signal player_unregistered

var players : Dictionary = {}
var my_info : Dictionary = {}
var my_team : int = -1
var game_started : bool = false

var current_team : int = 0
var player_indexes : Array = [0,0]



remotesync func register_player(player_id : int,player_info : Dictionary) -> void:
	players[player_id] = player_info
	if player_id == get_tree().get_network_unique_id():
		Lobby.my_team = player_info[INFO_TEAM]
	emit_signal("player_registered",player_id,player_info)

remotesync func unregister_player(player_id : int) -> void:
	players.erase(player_id)
	emit_signal("player_unregistered",player_id)

remote func _server_register_player(player_info):
	player_info[INFO_TEAM] = current_team
	player_info[INFO_INDEX] = player_indexes[current_team]
	player_info[INFO_CHAMPION] = "none"
	player_info[INFO_LOCKED_IN] = false
	player_indexes[current_team] += 1
	current_team = 1-current_team
	rpc("register_player",get_tree().get_rpc_sender_id(),player_info)
	var champion_list = get_tree().current_scene.selected_champions
	var player_id = get_tree().get_rpc_sender_id()
	get_tree().current_scene.set_player_champion_icon(player_id,"none")



			

remote func get_registration():
	if get_tree().get_rpc_sender_id() == 1:
		rpc_id(1,"_server_register_player",my_info)
		

remotesync func goto_lobby():
	if get_tree().get_network_unique_id() == 1 or get_tree().get_rpc_sender_id() == 1:
		get_tree().change_scene_to(load("res://menu/lobby/lobby.tscn"))
		
remotesync func start_game():
	game_started = true
	if get_tree().get_rpc_sender_id() != 1: return
	get_tree().change_scene_to(load("res://world/world.tscn"))
	yield(get_tree(),"idle_frame"); yield(get_tree(),"idle_frame")
	if get_tree().is_network_server():
		for i in players:
			rpc("instantiate_player",i,players[i][INFO_CHAMPION])
			
remotesync func instantiate_player(player_id,champion_name):
	var player = load("res://champions/%s/%s.tscn" % [champion_name.to_lower(),champion_name.to_lower()]).instance()
	player.set_network_master(player_id)
	player.set_name(str(player_id))
	player.player_name = players[player_id][INFO_NAME]
	player.team = players[player_id][INFO_TEAM]
	player.global_position = get_tree().current_scene.get_node("spawnpos%d" % player.team).global_position
	player.champion_name = champion_name
	Game.get_player_node().add_child(player)

remotesync func uninstantiate_player(player_id):
	var player_node = Game.get_player_node().get_node(str(player_id))
	player_node.queue_free()
	Optimizations.remove_entity(player_node)
	unregister_player(player_id)
	
remotesync func game_end(winner : int, skola_path : NodePath):
	var skola = get_node(skola_path)
	var tween = Tween.new()
	add_child(tween)
	Game.camera.disabled = true
	tween.interpolate_property(Game.camera,"global_position",Game.camera.global_position,skola.global_position,2,Tween.TRANS_SINE)
	tween.start()

	
	
	
	
