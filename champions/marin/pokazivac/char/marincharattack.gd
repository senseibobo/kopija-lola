extends Projectile

func _ready():
	$Label.text = char([randi()%26+65,randi()%26+97,randi()%10+48][randi()%3])
