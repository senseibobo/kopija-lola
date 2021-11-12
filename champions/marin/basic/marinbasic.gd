extends Projectile

var number : int

var font : DynamicFont

func _ready():
	if number == 9:
		set_crit(additional_crit_damage + 0.5)
	$Label.text = str(number)
	update()
