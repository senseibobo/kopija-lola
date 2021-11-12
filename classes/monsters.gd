extends Entity
class_name Monster

onready var home_pos : Vector2 = global_position

var is_tetkica : bool = true
const hpbar_scene = preload("res://champions/other/minionhealthbar.tscn")

func _ready():
	hpbar = hpbar_scene.instance()
	hpbar.health_color = Color(0.8,0.1,0.1)
	add_child(hpbar)
	if get_tree().is_network_server():
		connect("taken_damage",self,"on_damage_taken")

func on_damage_taken(amount,source):
	rpc("target_entity",get_path_to(source))

func _process(delta):
	if get_tree().is_network_server() and (not is_instance_valid(target) or target.revealed_to & (team+1) == 0):
		rpc("set_path",Game.get_navigation_path(global_position,home_pos))
