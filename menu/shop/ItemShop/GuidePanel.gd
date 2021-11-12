extends Panel

export var item_rect : Rect2 = Rect2(0,0,48,64)
export var item_icon_size : Vector2 = Vector2(32,32)
export var cost_offset : float = 32
export var first_item_y : float = 20
export var item_spacing_y : float = 50
export var component_spacing_x : float = 128
export var tier_step : float = 48
var current_spacing : float
var current_item : Item
var dragging : bool = false
var dragging_offset : Vector2
var font : DynamicFont = DynamicFont.new()
onready var p = get_node("../../../../..")

func _ready():
	var data = preload("res://fonts/andadapro.ttf")
	font.font_data = data
	font.outline_size = 2
	font.outline_color = Color.black

func _process(delta):
	update()
	if Input.is_action_just_pressed("lmb") and get_global_rect().has_point(get_viewport().get_mouse_position()):
		dragging = true
	elif Input.is_action_just_released("lmb"):
		dragging = false

func _input(event):
	if event is InputEventMouseMotion and dragging:
		dragging_offset.x = clamp(dragging_offset.x+event.relative.x,-100,100)
		dragging_offset.y = clamp(dragging_offset.y+event.relative.y,-100,0)

func on_selected_item(item):
	current_item = item
	dragging_offset = Vector2()

func _draw():
	if current_item != null:
		draw_item_and_components(current_item,Vector2(rect_size.x/2,first_item_y)-item_rect.size/2+dragging_offset,0)

func draw_item_and_components(item,position,tier):
	var i = 0
	var s = float(item.components.size())
	for component in item.components:
		var c_item = Game.all_items[component]
		var pos = position + Vector2(((s-1)/2*(-component_spacing_x+tier*tier_step))+i*(component_spacing_x-tier*tier_step),item_spacing_y)
		draw_line(position+item_rect.size/2,pos+item_rect.size/2,Color.white,2.0)
		draw_item_and_components(c_item,pos,tier + 1)
		i+=1
	draw_item(item,position)
	

func draw_item(item,position):
	var cost = item.cost
	var p_components = p.items.duplicate()
	for component_id in item.components:
		var component = Game.all_items[component_id]
		if component in p_components:
			var index = p_components.find(component)
			p_components[index] = null
			cost -= component.cost
	item_rect.position = position
	var pos = item_rect.position + item_rect.size/2 - item_icon_size/2
	draw_texture_rect(item.texture,Rect2(pos,item_icon_size),false)
	var cost_position = pos + item_icon_size/2 + Vector2(0,cost_offset)
	draw_string(font,cost_position-Vector2(font.get_string_size(str(cost)).x/2,0),str(cost))
