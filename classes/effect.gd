class_name Effect
var name : String = "DEFAULT_EFFECT_NAME"
var duration : float = 1.0
var full_duration : float

var expired : bool = false
var persistent : bool = false
var effect_owner
var p


func apply():
	pass


func expire():
	if expired: return
	expired = true
	pass


func _process(delta):
	duration -= delta
	if p.get_tree().is_network_server() and duration <= 0:
		p.rpc("remove_effect",name)
