extends Objective
class_name Skola

func _ready():
	select_radius = 200

func death(source):
	targetable -= 1
	if get_tree().is_network_server():
		Lobby.rpc("game_end",source.team,Lobby.get_path_to(self))
	yield(get_tree().create_timer(2),"timeout")
	.death(source)
