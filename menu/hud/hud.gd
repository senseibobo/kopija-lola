extends CanvasLayer

class_name HUD

var font : DynamicFont
onready var p = get_parent()
onready var hpbar : HUDHealthbar = $Control/hud_down_bar/Health
onready var manabar : HUDHealthbar = $Control/hud_down_bar/Mana
onready var descriptions_node : Control = $Control/Descriptions
onready var minimap : Control = $Control/Minimap
onready var shop : Control = $Control/ItemShop
onready var itemslots : Control = $Control/ItemSlots
onready var deathrect : ColorRect = $DeathRect

var announcement_queue : Array
var current_announcement = null

func _ready():
	Game.hud = self
	for slot in itemslots.get_children():
		slot.connect("dragged_item",shop,"on_dragged_item")
	minimap.player = p
	var file = File.new()
	file.open("res://json/descriptions.json",file.READ)
	var descriptions = {}
	var text = file.get_as_text()
	descriptions = JSON.parse(text).result
	file.close()
	for child in descriptions_node.get_children():
		var desc = Dicts.dict_to_description(descriptions[p.champion_name.to_lower()][child.name])
		child.apply_description(desc)
	font = DynamicFont.new()
	var data = preload("res://fonts/andadapro.ttf")
	font.font_data = data
	font.outline_color = Color.black
	font.outline_size = 1
	var icons = [p.sprite.texture,p.first_ability_texture,p.second_ability_texture,p.ultimate_ability_texture]
	var i = 0
	for icon in $Control/Icons.get_children():
		icon.texture = icons[i]
		i += 1
	

func _process(delta):
	if not announcement_queue.empty() and not is_instance_valid(current_announcement):
		current_announcement = announcement_queue[0]
		add_child(announcement_queue[0])
		announcement_queue.pop_front()

func add_announcement(text,icon1,icon2):
	var announcement = preload("res://menu/hud/announcement/announcement.tscn").instance()
	announcement.text = text
	announcement.icon1 = icon1
	announcement.icon2 = icon2
	announcement_queue.append(announcement)
