extends Node2D
class_name Healthbar
export var length : float
export var height : float
export var yposition : float
export var health_color : Color = Color(0.1,0.8,0.1)
export var shield_color : Color = Color.gray
export var cripple_color : Color = Color.red
export var old_health_color : Color = Color.yellow
export var back_color : Color = Color(0,0,0,0)
export var border_size : float = 1
export var show_shield_cripple : bool = true 
var max_hs : float

var hp_length : float = 0.0
var cripple_length : float = 0.0
var shield_length : float = 0.0
var old_hp_length : float = 0.0
var hp_rect = Rect2()
var cripple_rect = Rect2()
var shield_rect = Rect2()
var cc = Color()
export var current_value : String = "current_health"
export var value : String = "health"
onready var p = get_parent()
	
func _process(delta):
	old_hp_length = lerp(old_hp_length,hp_length,5*delta)
	if show_shield_cripple:
		max_hs = max(1,min(p.get(value) + p.shield,max(min(p.get(current_value),p.get(value)) + p.shield,p.get(value))))
		shield_length = lerp(shield_length,length*p.shield/max_hs,25*delta)
		cripple_length = clamp(lerp(cripple_length,length*min(p.cripple,p.get(current_value))/max_hs,25*delta),0,p.get(value)*length)
		hp_length = clamp(lerp(hp_length,length*(p.get(current_value)/max_hs),25*delta),0,length)
	else:
		hp_length = clamp(lerp(hp_length,length*(p.get(current_value)/p.get(value)),25*delta),0,length)
	update()

func _draw():
	cc = health_color.inverted().linear_interpolate(cripple_color,0.6)
	hp_rect.position = Vector2(-length/2,-height-yposition)
	hp_rect.size = Vector2(hp_length,height)
	cripple_rect.position = Vector2(-length/2+hp_length-cripple_length,-height-yposition)
	cripple_rect.size = Vector2(cripple_length,height)
	shield_rect.position = Vector2(-length/2 + hp_length,-height-yposition)
	shield_rect.size = Vector2(shield_length,height)
	draw_rect(Rect2(-length/2,-height-yposition,length,height),back_color,true) #background
	draw_rect(Rect2(-length/2,-height-yposition,old_hp_length,height),old_health_color,true) #damage
	draw_rect(hp_rect,health_color,true) #health
	draw_rect(cripple_rect,cripple_color,true) #cripple
	draw_rect(shield_rect,shield_color,true) #shield
	draw_rect(Rect2(-length/2,-height-yposition,length,height),Color.black,false,border_size) #border
