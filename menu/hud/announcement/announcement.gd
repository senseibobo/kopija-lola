extends Control

export var margin_y : float = 200
export var text : String = "Protivnicki nastavnik je porazen"

export var icon_size : Vector2 = Vector2(8,8)
export var icon_spacing : float = 8

export var duration : float = 2.5
export var fade_out_duration : float = 0.5

var icon1 : Texture = preload("res://icon.png")
var icon2 : Texture = preload("res://champions/marin/bodyslam/bodyslamicon.png")

onready var tween : Tween = $Tween

func _ready():
	yield(get_tree().create_timer(duration),"timeout")
	tween.interpolate_property(self,"modulate",Color(1,1,1,1),Color(1,1,1,0),fade_out_duration,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
	tween.start()
	yield(tween,"tween_all_completed")
	queue_free()

func _process(delta):
	update()
	

func _draw():
	var size = get_font("").get_string_size(text)
	var pos = Vector2(rect_size.x/2-size.x/2,margin_y)
	draw_string(get_font(""),pos,text)
	var ipos = pos + (icon_size.x + icon_spacing)*Vector2.LEFT + (icon_size.y+size.y/2)*Vector2.UP*0.5
	if icon1 != null:
		draw_texture_rect(icon1,Rect2(ipos,icon_size),false)
	ipos = pos + (icon_spacing + size.x)*Vector2.RIGHT + (icon_size.y+size.y/2)*Vector2.UP*0.5
	if icon2 != null:
		draw_texture_rect(icon2,Rect2(ipos,icon_size),false)
