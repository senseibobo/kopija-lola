extends Control

signal dragged_item

var item : Item setget set_item,get_item

var dragging : bool = false
var dragging_offset : Vector2

onready var description = $ItemDescriptionPanel
onready var texture_rect = $TextureRect
onready var p = get_node("../../../..")
onready var my_index = int(name[name.length()-1])-1

func _ready():
	p.connect("item_set",self,"on_item_set")

func on_item_set(index,new_item):
	if index == my_index:
		set_item(new_item)

func _process(delta):
	if Input.is_action_just_pressed("lmb") and texture_rect.get_global_rect().has_point(get_viewport().get_mouse_position()):
		dragging = true
		dragging_offset = texture_rect.get_global_rect().position - get_viewport().get_mouse_position()
	if dragging:
		texture_rect.rect_global_position = get_viewport().get_mouse_position() + dragging_offset
		if Input.is_action_just_released("lmb"):
			emit_signal("dragged_item",my_index,texture_rect.rect_global_position)
			dragging = false
			texture_rect.rect_position = Vector2()


func set_item(value):
	item = value
	if item != null:
		texture_rect.texture = item.texture
	else:
		texture_rect.texture = null
func get_item():
	return item

func _on_ItemSlot_mouse_entered():
	if item != null:
		description.visible = true
		description.on_selected_item(item)
	


func _on_ItemSlot_mouse_exited():
	description.visible = false
