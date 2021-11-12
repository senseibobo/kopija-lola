extends Control

onready var ability : int = get_index()
var description : Description
onready var p = get_node("../../../..")

func apply_description(new_description : Description):
	description = new_description
	update_description()

func stretch_to_fit():
	$NinePatchRect/AbilityDescription.visible = false
	$NinePatchRect/AbilityDescription.visible = true
	$NinePatchRect.margin_top = -$NinePatchRect/AbilityDescription.rect_size.y-90
#	$NinePatchRect/AbilityDescription.visible = false
#	$NinePatchRect/AbilityDescription.visible = true

func _ready():
	$NinePatchRect.visible = false
	


func _process(delta):
	pass#$NinePatchRect.rect_position = get_viewport().get_mouse_position()

func update_description():
	$NinePatchRect/AbilityName.text = description.ability_name
	var temp_args = description.args
	$NinePatchRect/AbilityDescription.bbcode_text = description.ability_description
	for arg in temp_args:
		$NinePatchRect/AbilityDescription.bbcode_text = $NinePatchRect/AbilityDescription.bbcode_text.format({arg : p.get(arg)})
	$NinePatchRect/AbilityCooldown.text = ("No cooldown" if p.cooldowns[ability] <= 0 else"%.1fs" % p.cooldowns[ability])
	$NinePatchRect/AbilityLevel.text = ("" if ability == 0 else "%d/%d" % [p.ability_levels[ability], 8 if ability != 3 else 4])
	$NinePatchRect/AbilityManaCost.text = ("No cost" if p.mana_costs[ability]<=0 else "%.0f mana" % p.mana_costs[ability])
	stretch_to_fit()

func _on_mouse_entered():
	update_description()
	$NinePatchRect.visible = true

func _on_mouse_exited():
	$NinePatchRect.visible = false
