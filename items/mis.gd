extends Item

func _init():
	id = 16
	name = "Mis"
	cost = 1300
	texture = preload("res://items/mis.png")
	components = [5,6]
	attack_damage = 40
	cooldown_reduction = 0.15
