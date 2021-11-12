extends Control
tool
class_name StatCounter
export var stat : String = "attack_damage"
export var icon : Texture = preload("res://menu/hud/icons/attack_damage.png")
export var format : String = "%.0f"
export var update_stat_icon : bool setget set_update_stat_icon,get_update_stat_icon
onready var p = get_node("../../../..")
onready var label = $Label
onready var texture_rect = $TextureRect
func set_update_stat_icon(value):
	texture_rect.texture = icon
func get_update_stat_icon():
	return update_stat_icon

func _process(delta):
	if not Engine.editor_hint:
		label.text = format % p.get(stat)

func _ready():
	if not Engine.editor_hint:
		texture_rect.texture = icon
