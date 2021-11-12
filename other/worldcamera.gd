extends Camera2D
class_name WorldCamera
var unlocked : bool
var camera_speed = 1500
var following
var disabled : bool = false

var mouse_on_edge = {
	"right": false,
	"left": false,
	"down": false,
	"up": false
}

export var zoom_amount : float = 1.55
export var min_zoom : float = 0.4
export var max_zoom : float = 2.0

func _ready():
	zoom = Vector2(zoom_amount,zoom_amount)
	set_as_toplevel(true)
	process_priority = -1
	process_mode = Camera2D.CAMERA2D_PROCESS_IDLE
	#Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func _process(delta):
	if disabled: return
	zoom = lerp(zoom,Vector2(zoom_amount,zoom_amount),10*delta)
	if Input.is_action_just_pressed("unlock_camera") and following != null:
		unlocked = !unlocked
	if unlocked:
		var right = Input.is_action_pressed("ui_right") or mouse_on_edge["right"]
		var left = Input.is_action_pressed("ui_left") or mouse_on_edge["left"]
		var down = Input.is_action_pressed("ui_down") or mouse_on_edge["down"]
		var up = Input.is_action_pressed("ui_up") or mouse_on_edge["up"]
		var hmove = int(right)-int(left)
		var vmove = int(down)-int(up)
		var move = Vector2(hmove,vmove)
		global_position += move*camera_speed*delta
	elif following != null:
		global_position = following.global_position

func _input(event):
	if event is InputEventMouseMotion:
		mouse_on_edge["left"] = (event.position.x < 5)
		mouse_on_edge["right"] = (event.position.x > 1275)
		mouse_on_edge["up"] = (event.position.y < 5)
		mouse_on_edge["down"] = (event.position.y > 715)
	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			zoom_amount -= 0.1
		elif event.button_index == BUTTON_WHEEL_DOWN:
			zoom_amount += 0.1
		zoom_amount = clamp(zoom_amount,min_zoom,max_zoom )
		
