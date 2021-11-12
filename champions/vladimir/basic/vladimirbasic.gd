extends Node2D

var direction : Vector2 = Vector2( 0.447214, 0.894427 )
var _range : float = 100.0
var attack_speed : float = 0.7

func _ready():
	$Sprite.rotation = PI/2+direction.angle_to_point(Vector2(0,0))
	$Sprite.position = direction*20
	$Tween.interpolate_property($Sprite,"position",direction*20,direction*_range,0.1/attack_speed,Tween.TRANS_CUBIC,Tween.EASE_IN)
	$Tween.start()
	yield($Tween,"tween_completed")
	$Tween.interpolate_property($Sprite,"position",$Sprite.position,direction*20,0.4/attack_speed,Tween.TRANS_CUBIC,Tween.EASE_OUT)
	$Tween.start()
	yield($Tween,"tween_completed")
	queue_free()
	
