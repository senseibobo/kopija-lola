extends Polygon2D
tool
export var flip : bool = false setget set_flip,get_flip
export var offset_polygon : bool = false setget set_offset_polygon,get_offset_polygon
export var offs : Vector2
export var resize_polygon : bool = false setget set_resize_polygon,get_resize_polygon
export var resize : float

func set_resize_polygon(value):
	var array = Array(polygon)
	for i in array.size():
		array[i] = (array[i]-Vector2(2500,2500))*resize+Vector2(2500,2500)
	polygon = array

func get_resize_polygon():
	return resize_polygon

func set_offset_polygon(value):
	var array = Array(polygon)
	for i in array.size():
		array[i] += offs
	polygon = array

func get_offset_polygon():
	return offset_polygon

func get_flip():
	return flip

func set_flip(value):
	var array = Array(polygon)
	for i in array.size():
		array[i] = Vector2(5000,5000)-array[i]
	polygon = array
