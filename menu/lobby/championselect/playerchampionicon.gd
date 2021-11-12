extends Control

onready var label = $TextureRect/Label
onready var texture_rect = $TextureRect

func set_text(new_text):
	label.text = new_text

func set_icon(new_icon):
	if new_icon != null:
		texture_rect.texture = new_icon
