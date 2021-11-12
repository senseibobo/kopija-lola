extends Node2D

var angle : float
var dir : int = -1
var attack_speed : float = 1

func _ready():
	$Tween.interpolate_property($Sprite,"rotation",angle-dir*PI/2,angle+dir*PI/2,0.5/attack_speed,Tween.TRANS_BACK,Tween.EASE_OUT)
	$Sprite.flip_v = bool((-dir+1)/2)
	$Tween.start()
	yield($Tween,"tween_all_completed")
	queue_free()
