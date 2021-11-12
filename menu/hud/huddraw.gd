extends Control

onready var ultimate_ability_cooldown_timer : float
export var champion_position : Vector2
export var abilities_position : Vector2
export var abilities_separation : float
export var items_position : Vector2
export var items_size : Vector2 = Vector2(32,32)
export var items_separation : Vector2 = Vector2(4,4)
export var max_items_columns : int = 3
var items : Array
onready var p = get_node("../../..")

var draw_descriptions : Array

var font : DynamicFont

func _ready():
	font = DynamicFont.new()
	var data = preload("res://fonts/andadapro.ttf")
	font.font_data = data
	font.outline_color = Color.black
	font.outline_size = 1

func _draw():
	draw_string(font,Vector2(100,100),"%f" % Engine.get_frames_per_second())
	var rect = Rect2(champion_position,Vector2(64,64))
	draw_texture_rect(p.sprite.texture,rect,false)
	rect = Rect2(abilities_position,Vector2(60,61))
	var tex = [null,p.first_ability_texture,p.second_ability_texture,p.ultimate_ability_texture]
	for ability in range(1,4):
		draw_texture_rect(tex[ability],rect,false)
		if p.ability_levels[ability] == 0:
			draw_rect(rect,Color(0,0,0,0.5))
		draw_cooldown(rect,p.cooldown_timers[ability],p.cooldowns[ability])
		rect.position.x += abilities_separation + 60
	
#	for i in range(6):
#		var item = p.items[i] as Item
#		var pos = (i%max_items_columns)*Vector2.RIGHT*(items_size.x+items_separation.x)
#		pos += (i/max_items_columns)*Vector2.DOWN*(items_size.y+items_separation.y)
#		rect = Rect2(items_position+pos,items_size)
#		if item != null:
#			draw_texture_rect(item.texture,rect,false)
			
	
func _process(delta):
	update()

func draw_cooldown(rect,a,b):
	if a > 0 and b != 0:
		draw_rect(Rect2(rect.position,rect.size*Vector2(a/b,1)),Color(0,0,0,0.5))
		var cd_string = "%.*f" % [1,a]
		draw_string(font,rect.position + rect.size/2 - font.get_string_size(cd_string)*Vector2(1,-0.5)/2,cd_string )

func _on_ability_mouse_entered(ability_number : int) -> void:
	draw_descriptions[ability_number].visible = true

func _on_ability_mouse_exited(ability_number : int) -> void:
	draw_descriptions[ability_number].visible = false
