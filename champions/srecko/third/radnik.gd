extends Pet
class_name Radnik

const hpbar_scene = preload("res://champions/other/minionhealthbar.tscn")

var basic_index = 0
const basic_string = "SRECKO"

func _ready():
	hpbar = hpbar_scene.instance()
	add_child(hpbar)

remotesync func basic_attack(args):
	if not is_instance_valid(target): return
	var damage = Damage.new()
	damage.magic_damage = pet_owner.get_basic_damage()
	if basic_index == basic_string.length()-1: damage.physical_damage = pet_owner.get_o_damage()
	damage.crit_percent += 1 if fmod(args[ARGS.RANDOM],100) < 100*pet_owner.critical_chance else 0
	var proj = pet_owner.basic_scene.instance()
	proj.projectile_owner = pet_owner
	proj.get_node("Label").text = basic_string[basic_index]
	proj.name = args[ARGS.NAME]
	proj.global_position = args[ARGS.GPOS]
	proj.team = team
	proj.damage = damage
	proj.target = get_node(args[ARGS.TARGET_ENEMY_PATH])
	Game.get_projectile_node().add_child(proj)
	basic_index=(basic_index+1)%basic_string.length()

func first_ability(args):
	var direction : Vector2 = global_position.direction_to(args[ARGS.MPOS])
	var angle = PI+direction.angle()
	var vfxargs = {
		VFX.ARGS_ROTATION : angle,
		VFX.ARGS_SIZE : 20
	}
	VFX.create_effect(VFX.CONE,global_position,Color.black,7.0,vfxargs)
	if get_tree().is_network_server():
		var entities = Game.get_entities_in_cone(global_position, 700.0, -direction, 40, team, true)
		if get_tree().is_network_server():
			for entity in entities:
				var effect = SreckoSleep.new()
				effect.effect_owner = pet_owner
				effect.duration = 3.0
				effect.wake_up_damage = pet_owner.get_sleep_damage()
				effect.name = "SRECKO_SLEEP"
				entity.rpc("apply_effect",inst2dict(effect))
	
func second_ability(args):
	var proj = pet_owner.button_scene.instance()
	proj.global_position = global_position
	proj.damage = Damage.new()
	proj.projectile_owner = pet_owner
	proj.team = team
	proj.name = args[ARGS.NAME]+name
	proj.direction = global_position.direction_to(args[ARGS.MPOS])
	proj.connect("hit_enemy",self,"on_button_hit",[proj])
	Game.get_projectile_node().add_child(proj)

func on_button_hit(proj,body):
	VFX.create_effect(VFX.EXPLOSION,proj.global_position,Color.white,2.5)
	if get_tree().is_network_server():
		var entities = Game.get_entities_in_range(proj.global_position,250,team,true,false)
		for entity in entities:
			var damage = Damage.new()
			damage.physical_damage = pet_owner.get_button_damage()
			entity.take_damage(Dicts.damage_to_dict(damage),entity.get_path_to(self))
