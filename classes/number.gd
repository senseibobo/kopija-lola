extends Resource
class_name Number

var color : Color
var text : String
var life_left : float = 0.5
var position : Vector2
var velocity : Vector2 = Vector2(100,-100)
var gravity : float = 400
var scale : Vector2
var icon : Texture = null

func _init(text : String, color : Color, position : Vector2, scale : Vector2, icon : Texture = null):
	self.text = text
	self.color = color
	self.position = position
	self.scale = scale
	self.icon = icon
	
