extends Healthbar
class_name TurretHealthbar

export var splits : int = 3

func _draw():
	for i in range(splits-1):
		var konst = length/splits
		var x = -length/2 + (1+i)*konst 
		draw_line(Vector2(x,-yposition-height),Vector2(x,-yposition),Color.black,1)
