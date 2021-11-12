extends Panel

signal item_selected

var item : Item
export var icon_rect : Rect2 = Rect2(16,16,32,32)
export var name_position : Vector2 = Vector2(56,38)
export var stat_position : Vector2 = Vector2(16,80)
export var stat_spacing : float = 20
const stats = ["movement_speed","health","armor","magic_resist",
"health_regen","attack_damage","attack_speed","ability_power","life_steal",
"tenacity","critical_chance","cooldown_reduction","mana","mana_regen"]
func _draw():
	if item == null: return
	draw_texture_rect(item.texture,icon_rect,false)
	draw_string(get_font(""),name_position,item.name,Color.yellow)
	
	var position = stat_position
	
	for stat in stats:
		if item.get(stat) > 0:
			draw_string(get_font(""),position,format_stat(stat,item.get(stat)))
			position += Vector2(0,stat_spacing)

func format_stat(stat_name,amount):
	match stat_name:
		"movement_speed": return "+%.0f Movement Speed" % amount
		"health": return "+%.0f Health" % amount
		"armor": return "+%.0f Armor" % amount
		"magic_resist": return "+%.0f Magic Resist" % amount
		"health_regen": return "+%.0f Health Regen" % amount
		"attack_damage": return "+%.0f Attack Damage" % amount
		"attack_speed": return "+%.0f%% Attack Speed" % (amount*100.0)
		"ability_power": return "+%.0f Ability Power" % amount
		"life_steal": return "+%.0f%% Life Steal" % (amount*100.0)
		"tenacity": return "+%.0f%% Tenacity" % (amount*100.0)
		"critical_damage": return "+%.0f%% Critical Damage" % (amount*100.0)
		"cooldown_reduction": return "+%.0f%% Cooldown Reduction" % (amount*100.0)
		"mana": return "+%.0f Mana" % amount
		"mana_regen": return "+%.0f Mana Regen" % amount

func on_selected_item(new_item):
	item = new_item
	emit_signal("item_selected",new_item)
	update()
