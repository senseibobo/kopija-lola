extends Area2D

var duration : float
var kosa : Champion

func _ready():
	if get_tree().is_network_server():
		connect("body_exited",self,"_server_body_exited")

func _server_body_exited(body):
	if body == kosa:
		rpc("remove_arena")

remotesync func remove_arena():
	for player in Game.get_players(kosa.team,true):
		player.remove_effect("KOSA_ARENA")
	queue_free()
		

func _process(delta):
	duration -= delta
	if get_tree().is_network_server() and duration <= 0:
		rpc("remove_arena")
		
