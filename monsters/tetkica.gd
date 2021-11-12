extends Monster


remotesync func basic_attack(args):
	var damage : Damage = Damage.new()
	damage.physical_damage = attack_damage
	var proj = Projectile.new()
	proj.projectile_owner = self
	proj.target = get_node(args[ARGS.TARGET_ENEMY_PATH])
	proj.global_position = args[ARGS.GPOS]
	proj.damage = damage
	proj.name = args[ARGS.NAME]
	proj.team = team
	proj.speed *= 1.2
	proj.scale *= 0.4
	Game.get_projectile_node().add_child(proj)
