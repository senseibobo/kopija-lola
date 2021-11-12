extends Entity

class_name Objective

var hpbar_scene = preload("res://champions/other/turrethealthbar.tscn")

export var protected_by : Array 

var unlocked : bool = true

func _ready():
	hpbar = hpbar_scene.instance()
	add_child(hpbar)	
	if get_tree().is_network_server():
		for protector in protected_by:
			var protector_instance = get_parent().get_parent().get_node("Turrets/" + protector)
			unlocked = false
			protector_instance.connect("death",self,"rpc",["unlock"])
	if not unlocked:
		rpc("lock")
			
remotesync func lock():
	unlocked = false
	targetable -= 1
	hpbar.visible = false
	

remotesync func unlock():
	if unlocked: return
	unlocked = true
	var protected = false
	hpbar.visible = true
	targetable += 1

func killed_entity(entity):
	pass
