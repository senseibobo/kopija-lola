extends Node2D

enum {
	EXPLOSION,
	CONE,
	ARGS_ROTATION,
	ARGS_SIZE
}
var size : float = 300
const explosion_scene = preload("res://vfx/explosion.tscn")
const cone_scene = preload("res://vfx/cone.tscn")

func _ready():
	z_index = 10

func create_effect(effect : int,pos : Vector2, color : Color = Color.white, effect_scale : float = 1.0, args : Dictionary = {}):
	var effect_inst : VisualEffect
	match effect:
		EXPLOSION: effect_inst = explosion_scene.instance()
		CONE: effect_inst = cone_scene.instance()
	effect_inst.global_position = pos
	effect_inst.modulate = color
	effect_inst.scale = Vector2(1,1)*effect_scale
	effect_inst.apply_args(args)
	add_child(effect_inst)
