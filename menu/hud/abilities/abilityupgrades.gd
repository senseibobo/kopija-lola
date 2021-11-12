extends Control

var revealed = false
onready var p = get_node("../../..")

onready var ability1 : Button = $Panel/ability1
onready var ability2 : Button  = $Panel/ability2
onready var ability3 : Button  = $Panel/ability3

onready var tween = $Tween

onready var panel = $Panel

func _ready():
	p.connect("level_up",self,"on_level_up")
	ability1.connect("pressed",p,"level_up_ability",[1])
	ability2.connect("pressed",p,"level_up_ability",[2])
	ability3.connect("pressed",p,"level_up_ability",[3])
	ability1.connect("pressed",self,"hide_if_done")
	ability2.connect("pressed",self,"hide_if_done")
	ability3.connect("pressed",self,"hide_if_done")
	reveal()

func on_level_up():
	reveal()

func hide_if_done():
	if not revealed: return
	for i in range(1,4):
		if p.can_level_up(i):
			return
	hide()

func _process(delta):
	if revealed:
		ability1.disabled = not p.can_level_up(1)
		ability2.disabled = not p.can_level_up(2)
		ability3.disabled = not p.can_level_up(3)
		hide_if_done()

func reveal():
	tween.interpolate_property(panel,"rect_position",Vector2(0,88),Vector2(0,0),0.3,Tween.TRANS_EXPO,Tween.EASE_IN_OUT)
	tween.start()
	revealed = true
func hide():
	tween.interpolate_property(panel,"rect_position",Vector2(0,0),Vector2(0,88),0.3,Tween.TRANS_EXPO,Tween.EASE_IN_OUT)
	tween.start()
	revealed = false
	

