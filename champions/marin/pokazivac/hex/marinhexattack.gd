extends Projectile

func _ready():
	$Label.text = char([randi()%10+48,randi()%6+65][randi()%2])
