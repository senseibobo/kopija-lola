extends Node2D

var numbers = []
var font : DynamicFont

func _ready():
	font = DynamicFont.new()
	var data = preload("res://fonts/andadapro.ttf")
	font.font_data = data
	font.outline_color = Color.black
	font.outline_size = 1
	font.size = 48
	z_index = 100

func add_number(text : String, color : Color, pos : Vector2, scale : Vector2, icon : Texture = null):
	numbers.append(Number.new(text,color,pos,scale,icon))
	
	
func _process(delta):
	for number in numbers:
#		number = number as DamageNumber
		number.life_left -= delta
		if number.life_left <= 0:
			numbers.erase(number)
		number.velocity += Vector2.DOWN*number.gravity*delta
		number.position += number.velocity*delta
	update()
func _draw():
	for number in numbers:
		number = number as Number
		var color = number.color
		color.a = pow(number.life_left * 2.0,1/2)
		draw_set_transform(Vector2(number.position),0,Vector2(1,1)*number.scale)
		draw_string(font,Vector2(),number.text,color)
		draw_set_transform(Vector2(),0,Vector2(1,1))
		
	
	
	
	
	
	
	
	
	
	
	
	
		
	
