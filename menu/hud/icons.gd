extends Control


onready var p = get_node("../../..")
var font : DynamicFont


func _ready():
	font = get_font("").duplicate()
	font.outline_color = Color.black
	font.outline_size = 1

func _process(delta):
	update()

func _draw():
	for child in get_children():
		var index = child.get_index()
		if index == 0: continue
		var cd = p.cooldown_timers[index]
		var pos = child.rect_position
		var size = child.rect_size
		var rect = Rect2(pos,size * Vector2(1 if p.ability_levels[index] <= 0 else cd/p.cooldowns[index],1))
		draw_rect(rect,Color(0.0,0.0,0.0,0.5),true)
		if cd > 0 and cd < 500:
			var cds = "%.1f" % cd
			draw_string(font,pos+size/2-font.get_string_size(cds)*Vector2(0.5,0.0),cds)
		
