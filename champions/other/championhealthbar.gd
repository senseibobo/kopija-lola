extends Healthbar
class_name ChampionHealthbar

export var mana_color : Color = Color(0.2,0.2,0.9,1.0)
export var mana_height : float = 3
export var mana_length : float = 120
var old_mana : float
var font : Font

const lines : Array = [
	{0 : 100, 1 : 0.5, 2 : 1},
	{0 : 500, 1 : 0.67, 2 : 1.2},
	{0 : 2500, 1 : 0.8, 2 : 1.5},
	{0 : 10000, 1 : 0.9, 2 : 2}
]

func _ready():
	p = get_parent()
	font = DynamicFont.new()
	var data = preload("res://fonts/andadapro.ttf") as DynamicFontData
	font.font_data = data
	if int(get_parent().name) == get_tree().get_network_unique_id():
		health_color = Color(0.1,0.8,0.1)

func _enter_tree():
	font = DynamicFont.new()
	var data = preload("res://fonts/andadapro.ttf") as DynamicFontData
	font.font_data = data

func _process(delta):
	old_mana = lerp(old_mana,p.current_mana,5*delta)

func _draw():
	draw_rect(Rect2(-mana_length/2,-yposition,mana_length,mana_height),back_color) #back
	draw_rect(Rect2(-mana_length/2,-yposition,mana_length*old_mana/p.mana,mana_height),old_health_color,true) #damage
	draw_rect(Rect2(-mana_length/2,-yposition,mana_length*p.current_mana/p.mana,mana_height),mana_color,true) #health
	draw_rect(Rect2(-mana_length/2,-yposition,mana_length,mana_height),Color.black,false,1,false) #border


	for i in lines:
		draw_support_lines(i[0],i[1],i[2])
	
	draw_name(p.player_name)
	draw_level(p.level)
	
func draw_level(l):
	draw_string(font,Vector2(-length/2-font.get_string_size(str(l)).x-4.0,-height-yposition+font.get_height()/2),str(l))
	
func draw_name(t):
	draw_string(font,Vector2(-font.get_string_size(t).x/2,-height-yposition-4.0),t)
		

func draw_support_lines(div,h,w):
	for i in range(int(max_hs)/div):
		var konst = length/(max_hs/div)
		if (i+1)*konst >= length: break 
		var xpos = -length/2 + (i+1) * konst
		draw_line(Vector2(xpos,-height-yposition),Vector2(xpos,-height-yposition+height*h),Color.black,w)
