extends Node2D


var surface_damage_per_second : float
var surface_duration : float
var team : int
var direction : Vector2
var radius : float = 1000
var angle : float
var slow_percentage : float
var milica : Champion
const SURFACE_TICK : float = 0.15
var timer

onready var tween : Tween = $Tween
onready var sprite : Sprite = $Sprite

func _ready():
	var mat = sprite.get_material()
	tween.interpolate_property(mat,"shader_param/range",0,2,0.3)
	tween.interpolate_property(self,"radius",0,1000,0.3)
	tween.start()
	rotation = direction.angle()
	if get_tree().is_network_server():
		timer = Timer.new()
		timer.autostart = true
		timer.one_shot = false
		timer.connect("timeout",self,"_server_tick")
		add_child(timer)
		timer.start(SURFACE_TICK)

func _server_tick():
	for entity in Game.get_entities_in_cone(global_position, radius, direction, angle, team,true):
		var damage = Damage.new()
		damage.physical_damage = surface_damage_per_second * SURFACE_TICK
		var effect = Slow.new()
		effect.duration = SURFACE_TICK
		effect.slow_percentage = slow_percentage/100.0
		effect.effect_owner = milica
		effect.name = "SURFACE_SLOW"
		entity.take_damage(Dicts.damage_to_dict(damage),entity.get_path_to(milica))
		entity.rpc("apply_effect",inst2dict(effect))

func _process(delta):
	surface_duration = move_toward(surface_duration,0,delta)
	if surface_duration <= 0: queue_free()
	pass
