class_name Item

var id : int
var name : String
var cost : float
var texture : Texture
var components : Array

var movement_speed : float
var health : float
var armor : float
var magic_resist : float
var health_regen : float
var attack_damage : float
var attack_speed : float
var ability_power : float
var life_steal : float
var tenacity : float
var critical_chance : float
var cooldown_reduction : float
var mana : float
var mana_regen : float

func _process(delta):
	pass

static func get_item_by_id(item_id):
	pass
