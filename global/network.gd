extends Node


func _ready():
	get_tree().connect("connected_to_server",self,"_connected_to_server")
	get_tree().connect("connection_failed",self,"_connection_failed")
	get_tree().connect("server_disconnected",self,"_server_disconnected")


func create_server(port : int, max_clients : int = 10):
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(port,max_clients)
	get_tree().connect("network_peer_connected",self,"_peer_connected")
	get_tree().connect("network_peer_disconnected",self,"_peer_disconnected")
	get_tree().set_network_peer(peer)
	
func join_server(ip : String = "localhost", port : int = 7777):
	var peer = NetworkedMultiplayerENet.new()
	var error = peer.create_client(ip,port)
	get_tree().set_network_peer(peer)
	return error

func check_ip(ip : String) -> bool:
	var nums = ip.split(".")
	if nums != 4: return false
	for num in nums: if num < 0 or num > 255: return false
	return true



func _connected_to_server():
	#Lobby.rpc_id(1,"verify_info",Lobby.my_info)
	Lobby.rpc_id(1,"_server_register_player",Lobby.my_info)
	print("CONNECTED TO SERVER")

func _connection_failed():
	print("FAILED TO CONNECT TO SERVER")

func _peer_connected(player_id):
	print("CONNECTED TO NETWORK PEER ID:%s" % str(player_id))
	for i in Lobby.players:
		Lobby.rpc("register_player",i,Lobby.players[i])
	Lobby.rpc_id(player_id,"goto_lobby")

func _peer_disconnected(player_id):
	print("DISCONNECTED FROM NETWORK PEER ID:%s" % str(player_id))
	if Lobby.game_started:
		Lobby.uninstantiate_player(player_id)
	Lobby.unregister_player(player_id)

func _server_disconnected():
	get_tree().network_peer = null
	Lobby.players = {}
	get_tree().change_scene("res://menu/start/startmenu.tscn")
	print("DISCONNECTED FROM SERVER")

func kick_player(player_id):
	if get_tree().is_network_server():
		rpc_id(player_id,"disconnect_from_server")
	
remote func disconnect_from_server():
	_server_disconnected()
