extends Node2D
class_name Projectile

signal hit_enemy

export var speed : float = 300.0
var direction : Vector2
export var homing : bool = true
export var acceleration : float = 0.0
export var lifetime : float = 10.0
var life : float = 0.0
export var target_only : bool = true
export var hit_enemy : bool = true
export var hit_friend : bool = false
export var gameplay_radius : float = 1.0
var target : Node2D
var team : int
var damage : Damage
var additional_crit_damage : float = 0.0 setget set_crit
var projectile_owner : Entity
onready var start_point : Vector2 = global_position

func set_crit(value):
	additional_crit_damage = value
	damage.crit_percent += value

func _server_hit(body):
	if target_only and body != target: return
	if not hit_friend and body.team == team: return
	if not hit_enemy and body.team != team: return
	var source_path = null if not is_instance_valid(projectile_owner) else body.get_path_to(projectile_owner)
	body.take_damage(Dicts.damage_to_dict(damage),source_path)
	rpc("hit",get_path_to(body))

remotesync func hit(body_path):
	var body = get_node_or_null(body_path)
	if is_instance_valid(body):
		emit_signal("hit_enemy",body)
	death()

remotesync func death():
	queue_free()

func _process(delta):
	if homing and is_instance_valid(target) and not target.dead:
		global_position = global_position.move_toward(target.global_position,delta*speed)
	elif not homing:
		global_position += speed*direction*delta
	elif get_tree().is_network_server():
		rpc("death")
	if get_tree().is_network_server():
		var colliders = []
		if hit_enemy != hit_friend:
			colliders = Optimizations.check_collision_gameplay(self,team,hit_enemy)
		else:
			colliders = Optimizations.check_collision_gameplay(self,-1)
		if colliders != []:
			_server_hit(colliders[0])
	life += delta
	speed = max(speed + acceleration*delta,0)
	if life >= lifetime: death()
