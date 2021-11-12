extends Control


func _input(event):
	if (event is InputEventMouseButton or event.is_action_pressed("esc")) and not Rect2(rect_position,rect_size).has_point(get_viewport().get_mouse_position()):
		release_focus()
