extends Node2D

export var speed : float = 2.0

func _ready():
	var colors = [
		Color(1.0,0.0,0.0),
		Color(0.0,1.0,0.0),
		Color(0.0,0.0,1.0),
		Color(1.0,1.0,0.0),
		Color(1.0,0.0,1.0),
		Color(0.0,1.0,1.0)
	]
	get_material().set_shader_param("traveller_color",colors[randi()%6])

func _process(delta):
	rotation = fmod(rotation+delta*speed,TAU)
