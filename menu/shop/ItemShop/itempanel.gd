extends Panel
class_name DescriptionPanel
signal selected_item

var item_list : Array setget set_item_list,get_item_list
var max_columns : int = 5
export var cost_offset : float = 32
export var item_margins : Vector2 = Vector2(16,16)
export var item_rect : Rect2 = Rect2(0,0,48,64)
export var item_icon_size : Vector2 = Vector2(32,32)
var hovered_item : int = -1
var selected_item : int = -1

var scroll_pos : float = 0.0
var new_scroll_pos : float = 0.0

var font : DynamicFont = DynamicFont.new()

onready var scroll_bar = $VScrollBar
onready var p = get_node("../../../../..")
onready var itemshop = get_node("../..")

func _input(event):
	if event is InputEventMouseButton:
		if event.is_action_pressed("lmb"):
			for i in item_list.size():
				if get_item_rect(i).has_point(get_viewport().get_mouse_position()-rect_position):
					selected_item = i
					emit_signal("selected_item",item_list[i])
					if event.doubleclick == true:
						p.attempt_purchase(item_list[i])
						
		elif event.is_action_pressed("rmb"):
			for i in item_list.size():
				if get_item_rect(i).has_point(get_viewport().get_mouse_position()-rect_position):
					p.attempt_purchase(item_list[i])
			
		elif event.button_index == BUTTON_WHEEL_DOWN:
			scroll_bar.value += 25
			new_scroll_pos = -scroll_bar.value
		elif event.button_index == BUTTON_WHEEL_UP:
			scroll_bar.value -= 25
			new_scroll_pos = -scroll_bar.value


func get_item_rect(index):
	var pos = Vector2(index%max_columns,index/max_columns)*item_rect.size + item_margins + Vector2(0,scroll_pos) + Vector2(0,cost_offset/4)
	var size = item_rect.size
	return Rect2(pos,size)

func set_item_list(value):
	item_list = value
	scroll_bar.max_value = 2*item_margins.y + value.size()/max_columns*item_rect.size.y
	scroll_bar.value = 0
	scroll_bar.page = rect_size.y-item_rect.size.y
	update()

func get_item_list():
	return item_list

func _process(delta):
	hovered_item = -1
	if itemshop.shop_revealed:
		for i in range(item_list.size()):
			if get_item_rect(i).has_point(get_viewport().get_mouse_position()-rect_position):
				hovered_item = i
	scroll_pos = lerp(scroll_pos,new_scroll_pos,8*delta)
	update()

func _ready():
	var data = preload("res://fonts/andadapro.ttf")
	font.font_data = data
	font.outline_color = Color.black
	font.outline_size = 2

func _draw():
	draw_items(item_list)

func draw_items(array : Array):
	var i = 0
	for item in array:
		if selected_item == i:
			draw_rect(get_item_rect(i),Color(1,1,1,0.5))
		elif hovered_item == i: 
			draw_rect(get_item_rect(i),Color(1,1,1,0.2))
		draw_item(i)
		i+=1

func draw_item(i):
	
	var item = item_list[i]
	var cost = item.cost
	var p_components = p.items.duplicate()
	for component_id in item.components:
		var component = Game.all_items[component_id]
		if component in p_components:
			var index = p_components.find(component)
			p_components[index] = null
			cost -= component.cost
	item_rect.position = Vector2(i%max_columns,i/max_columns)*item_rect.size+Vector2(0,scroll_pos) + item_margins
	var pos = item_rect.position + item_rect.size/2 - item_icon_size/2
	draw_texture_rect(item_list[i].texture,Rect2(pos,item_icon_size),false)
	var cost_position = pos + item_icon_size/2 + Vector2(0,cost_offset)
	draw_string(font,cost_position-Vector2(font.get_string_size(str(cost)).x/2,0),str(cost))


func _on_VScrollBar_value_changed(value):
	new_scroll_pos = -value
