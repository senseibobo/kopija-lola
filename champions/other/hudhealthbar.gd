extends Healthbar
class_name HUDHealthbar
var font : Font


export var value_regen : String

func _ready():
	font = DynamicFont.new()
	var data = preload("res://fonts/andadapro.ttf") as DynamicFontData
	font.font_data = data
	font.outline_color = Color.black
	font.outline_size = 1
	p = get_node("../../../..")

func _draw():
	draw_amount()
	
func draw_amount():
	var amount = "%.0f/%.0f" % [p.get(current_value),p.get(value)]
	draw_string(font,Vector2(0,-yposition+8)-font.get_string_size(amount)/2,amount)
	if value_regen == "": return
	var regen = "+%.2f/s" % p.get(value_regen)
	draw_string(font,Vector2(length/2,-yposition+8)-font.get_string_size(regen)*Vector2(1,0.5),regen)

