extends Node

enum {
	GLOBAL_POSITION,
	MOVEMENT_SPEED,
	HEALTH,
	ARMOR,
	MAGIC_RESIST,
	HEALTH_REGEN,
	ATTACK_DAMAGE,
	ATTACK_SPEED,
	ATTACK_RANGE,
	LIFE_STEAL,
	TENACITY,
	EXP_WORTH,
	ABILITY_POWER,
	PATH,
	CURRENT_HEALTH,
	BASIC_ATTACK_READY,
	CREEP_SCORE,
	MONEY,
	DEAD,
	WORTH,
	CREEP_SCORE_WORTH,
	TARGET,
	MOVEABLE,
	CASTABLE,
	ABLE_TO_BASIC,
	TARGETABLE,
	REVEALED_TO,
	SHIELDS,
	CRIPPLES,
	EFFECTS,
	LEVEL,
	ARMOR_PER_LEVEL,
	MANA,
	CRITICAL_CHANCE,
	COOLDOWNS,
	MANA_COSTS,
	ABILITY_LEVELS,
	CURRENT_MANA,
	EXPERIENCE,
	EXPERIENCE_NEEDED,
	ABILITY_POINTS,
	NAME,
	PHYSICAL,
	MAGIC,
	TRUE,
	PURE,
	HEAL,
	CRIT,
	DURATION,
	BLEED,
	POISON,
	CURSE,
	CRIT_EFFECT,
	AD_BOOST_PERCENT,
	AP_BOOST_PERCENT,
	AD_BOOST_FLAT,
	AP_BOOST_FLAT,
	SHIELD,
	SHIELD_AMOUNT,
	SHIELD_DECAYING,
	CRIPPLE,
	CRIPPLE_AMOUNT,
	CRIPPLE_DECAYING,
	TICK_TIME,
	SPEED,
	SLOW,
	DECAYING_SPEED,
	STUN,
	ROOT,
	SILENCE,
	DISARM,
	FEAR,
	CHARM,
	INVISIBILITY,
	CONFINE,
	CONFINE_RADIUS,
	CONFINE_POS,
	CAMOFLAGE,
	GHOSTING
	KNOCKBACK_VECTOR,
	KNOCKBACK,
	EFFECT_OWNER,
}



func damage_from_dict(dict : Dictionary) :
	var damage = Damage.new()
	damage.physical_damage = dict[PHYSICAL]
	damage.magic_damage = dict[MAGIC]
	damage.true_damage = dict[TRUE]
	damage.pure_damage = dict[PURE]
	damage.heal = dict[HEAL]
	damage.crit_percent = dict[CRIT]
	return damage

func damage_to_dict(damage) -> Dictionary:
	var dict = {}
	dict[PHYSICAL] = damage.physical_damage
	dict[MAGIC] = damage.magic_damage
	dict[TRUE] = damage.true_damage
	dict[PURE] = damage.pure_damage
	dict[HEAL] = damage.heal
	dict[CRIT] = damage.crit_percent
	return dict

func entity_to_dict(entity) -> Dictionary:
	var dict = {}
	dict[GLOBAL_POSITION] = entity.global_position
	dict[MOVEMENT_SPEED] = entity.movement_speed
	dict[HEALTH] = entity.health
	dict[ARMOR] = entity.armor
	dict[MAGIC_RESIST] = entity.magic_resist
	dict[HEALTH_REGEN] = entity.health_regen
	dict[ATTACK_DAMAGE] = entity.attack_damage
	dict[ATTACK_SPEED] = entity.attack_speed
	dict[LIFE_STEAL] = entity.life_steal
	dict[TENACITY] = entity.tenacity
	dict[EXP_WORTH] = entity.exp_worth
	dict[ABILITY_POWER] = entity.ability_power
	dict[PATH] = entity.path
	dict[CURRENT_HEALTH] = entity.current_health
	dict[CREEP_SCORE] = entity.creep_score
	dict[MONEY] = entity.money
	dict[DEAD] = entity.dead
	dict[WORTH] = entity.worth
	dict[TARGET] = "none" if not is_instance_valid(entity.target) else entity.get_path_to(entity.target)
	dict[MOVEABLE] = entity.moveable
	dict[CASTABLE] = entity.castable
	dict[ABLE_TO_BASIC] = entity.able_to_basic
	dict[TARGETABLE] = entity.targetable
	dict[REVEALED_TO] = entity.revealed_to
	dict[EFFECTS] = {}
	for effect in entity.effects:
		dict[EFFECTS][effect] = inst2dict(entity.effects[effect])
	return dict
	
func champion_to_dict(champion):
	var dict = entity_to_dict(champion)
	dict[LEVEL] = champion.level
	dict[MANA] = champion.mana
	dict[CRITICAL_CHANCE] = champion.critical_chance
	dict[COOLDOWNS] = champion.cooldowns
	dict[MANA_COSTS] = champion.mana_costs
	dict[ABILITY_LEVELS] = champion.ability_levels
	dict[CURRENT_MANA] = champion.current_mana
	dict[EXPERIENCE] = champion.experience
	dict[EXPERIENCE_NEEDED] = champion.experience_needed
	dict[ABILITY_POINTS] = champion.ability_points
	return dict
	
func apply_update_to_entity(entity, dict : Dictionary) -> void:
	entity.global_position = dict[GLOBAL_POSITION]
	entity.movement_speed = dict[MOVEMENT_SPEED]
	entity.health = dict[HEALTH]
	entity.armor = dict[ARMOR]
	entity.magic_resist = dict[MAGIC_RESIST]
	entity.health_regen = dict[HEALTH_REGEN]
	entity.attack_damage = dict[ATTACK_DAMAGE]
	entity.attack_speed = dict[ATTACK_SPEED]
	#entity.attack_range = dict[ATTACK_RANGE]
	entity.life_steal = dict[LIFE_STEAL]
	entity.tenacity = dict[TENACITY]
	entity.exp_worth = dict[EXP_WORTH]
	entity.ability_power = dict[ABILITY_POWER]
	entity.path = dict[PATH]
	entity.set_health(dict[CURRENT_HEALTH])
	entity.creep_score = dict[CREEP_SCORE]
	entity.money = dict[MONEY]
	entity.dead = dict[DEAD]
	entity.worth = dict[WORTH]
	#entity.creep_score_worth = dict[CREEP_SCORE_WORTH]
	entity.target = entity.get_node_or_null(dict[TARGET])
	entity.moveable = dict[MOVEABLE]
	entity.castable = dict[CASTABLE]
	entity.able_to_basic = dict[ABLE_TO_BASIC]
	entity.targetable = dict[TARGETABLE]
	entity.revealed_to = dict[REVEALED_TO]
	if entity.dead:
		entity.visible = false
	elif (entity.omnivisible or Lobby.my_team == entity.team) or entity.revealed_to & (Lobby.my_team+1) != 0:
		entity.visible = true
#	var new_effects = dict[EFFECTS]
#	for effect in new_effects:
#		var entity_effect = entity.get_effect(effect)
#		if entity_effect != null:
#			Dicts.apply_update_to_effect(entity_effect,dict[EFFECTS][effect])
#		else:
#			entity.rpc("request_effect",effect)
		
func apply_update_to_champion(champion,dict):
	apply_update_to_entity(champion,dict)
	champion.level = dict[LEVEL]
	champion.mana = dict[MANA]
	champion.critical_chance = dict[CRITICAL_CHANCE]
	champion.cooldowns = dict[COOLDOWNS]
	champion.mana_costs = dict[MANA_COSTS]
	champion.ability_levels = dict[ABILITY_LEVELS]
	champion.current_mana = dict[CURRENT_MANA]
	champion.experience = dict[EXPERIENCE]
	champion.experience_needed = dict[EXPERIENCE_NEEDED]
	champion.ability_points = dict[ABILITY_POINTS]

func dict_to_description(dict):
	var description = Description.new()
	description.ability_name = dict["name"]
	description.ability_description = dict["description"]
	description.args = dict["args"]
	return description
