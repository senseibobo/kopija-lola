extends Control

var selected_champions = [[null,null,null,null,null],[null,null,null,null,null]]

func _ready():
	var is_server = get_tree().is_network_server()
	$VBServer.visible = is_server
	$VBClient.visible = not is_server
	$VBClient/ChampionSelect/Panel.connect("selected_champion",self,"on_champion_selected")
	$VBClient/ChampionSelect/Panel.connect("locked_in",self,"on_lock_in")
	for player_id in Lobby.players:
		set_player_champion_icon(player_id,Lobby.players[player_id][Lobby.INFO_CHAMPION])

func set_player_champion_icon(player_id,champion_name):
	var team = Lobby.players[player_id][Lobby.INFO_TEAM]
	var index = Lobby.players[player_id][Lobby.INFO_INDEX]
	var sicon = get_node("Team%d/Player%d"%[team,index])
	sicon.visible = true
	sicon.set_text(Lobby.players[player_id][Lobby.INFO_NAME])
	sicon.set_icon(Game.all_champions[champion_name])
	

remote func update_champion_list(champion_list):
	selected_champions = champion_list
	for player_id in Lobby.players:
		var team = Lobby.players[player_id][Lobby.INFO_TEAM]
		var index = Lobby.players[player_id][Lobby.INFO_INDEX]
		var sicon = get_node("Team%d/Player%d"%[team,index])
		sicon.visible = true
		sicon.set_text(Lobby.players[player_id][Lobby.INFO_NAME])
		sicon.set_icon(champion_list[team][index])
			
			
var time = 0.0


func on_champion_selected(champion_name):
	rpc_id(1,"select_champion",champion_name)
	
remote func select_champion(champion_name):
	var sender = get_tree().get_rpc_sender_id()
	rpc("champion_selected",sender,champion_name)

remotesync func champion_selected(player_id,champion_name):
	var team = Lobby.players[player_id][Lobby.INFO_TEAM]
	var index = Lobby.players[player_id][Lobby.INFO_INDEX]
	set_player_champion_icon(player_id,champion_name)
	Lobby.players[player_id][Lobby.INFO_CHAMPION] = champion_name
	selected_champions[team][index] = champion_name

func on_lock_in(champion_name):
	rpc_id(1,"lock_in",champion_name)

remote func lock_in(champion_name):
	var sender = get_tree().get_rpc_sender_id()
	rpc("locked_in",sender,champion_name)

remotesync func locked_in(player_id,champion_name):
	set_player_champion_icon(player_id,champion_name)
	Lobby.players[player_id][Lobby.INFO_LOCKED_IN] = true
	
	

func _on_BTStartGame_pressed():
	if not get_tree().is_network_server(): return
	get_tree().network_peer.refuse_new_connections = true
	Lobby.rpc("start_game")
	

	
	
