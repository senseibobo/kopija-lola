extends Resource
class_name Damage

enum {
	PHYSICAL,
	MAGIC,
	TRUE,
	PURE,
	HEAL,
	CRIT
}

var physical_damage : float = 0.0
var magic_damage : float = 0.0
var true_damage : float = 0.0
var pure_damage : float = 0.0
var heal : float = 0.0
var crit_percent : float = 0.0


func multiply_by(number):
	physical_damage *= number
	magic_damage *= number
	true_damage *= number
	pure_damage *= number
	heal *= number



func print_self():
	print("""PHYSICAL: %f
	MAGIC: %f
	TRUE: %f
	PURE: %f
	HEAL: %f
	CRIT: %f""" % [physical_damage,magic_damage,true_damage,pure_damage,heal,crit_percent])


#func _init(PH : float = 0.0,MA : float = 0.0,TR : float = 0.0,PU : float = 0.0,CR : float = 0.0):
#	physical_damage = PH
#	magic_damage = MA
#	true_damage = TR
#	pure_damage = PU
#	crit_percent = CR
