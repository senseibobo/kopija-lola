extends KinematicBody2D

var direction : Vector2
export var speed : float = 600.0 
export var lifetime : float = 10.0
var damage : Damage
var projectile_owner

func _ready():
	if get_tree().is_network_server():
		$Projectile.connect("hit_enemy",self,"_server_enemy_hit")
	$Projectile.damage = damage

func _server_enemy_hit(body):
	rpc("enemy_hit")
remotesync func enemy_hit():
	queue_free()

func _process(delta):
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
	var collision = move_and_collide(direction*speed*delta)
	if collision:
		direction = direction.bounce(collision.get_normal())
	
