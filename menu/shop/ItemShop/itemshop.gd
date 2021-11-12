extends Control

var items : Array = []


var shop_revealed : bool = false

onready var n = $n
onready var item_panel = $n/ItemPanel
onready var tween = $n/Tween
onready var toggle_button = $n/ToggleButton
onready var description_panel = $n/DescriptionPanel
onready var guide_panel = $n/GuidePanel
onready var p = get_node("../../..")

func _ready():
	load_items()
	var sorted_items = sort_items_by_cost()
	item_panel.item_list = sorted_items
	item_panel.connect("selected_item",description_panel,"on_selected_item")
	item_panel.connect("selected_item",guide_panel,"on_selected_item")

	
func _unhandled_input(event):
	if event.is_action_pressed("open_shop"):
		toggle_shop()

func toggle_shop():
	if shop_revealed:
		hide_shop()
	else:
		reveal_shop()
	
func reveal_shop():
	tween.interpolate_property(n,"rect_position",Vector2(-n.rect_size.x,0),Vector2(),0.5,Tween.TRANS_SINE,Tween.EASE_OUT)
	tween.start()
	shop_revealed = true
	toggle_button.rect_scale = Vector2(1,1)


func hide_shop():
	tween.interpolate_property(n,"rect_position",Vector2(),Vector2(-n.rect_size.x,0),0.5,Tween.TRANS_SINE,Tween.EASE_OUT)
	tween.start()
	shop_revealed = false
	toggle_button.rect_scale = Vector2(-1,1)


func load_items():
	for item in Game.all_items:
		items.append(Game.all_items[item])

	

func sort_items_by_cost():
	var sorted = items
	for i in range(sorted.size()-1):
		for j in range(i+1,sorted.size()):
			if compare_costs(sorted[i],sorted[j]):
				var pom = sorted[i]
				sorted[i] = sorted[j]
				sorted[j] = pom
	return sorted

func search_items_by_name(search_query : String):
	var result = []
	var regex = RegEx.new()
	regex.compile(search_query.to_lower())
	for item in items:
		if regex.search(item.name.to_lower()):
			result.append(item)
	return result

func on_dragged_item(index,position):
	if item_panel.get_global_rect().has_point(position):
		p.rpc_id(1,"sell_item",index)
	

func compare_costs(item1,item2):
	return item1.cost > item2.cost


func _on_search(search_query):
	var result = search_items_by_name(search_query)
	item_panel.item_list = result

