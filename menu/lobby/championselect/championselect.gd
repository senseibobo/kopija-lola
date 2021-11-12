extends Panel

signal hovered_champion
signal selected_champion
signal locked_in

export var champion_icon_size : Vector2 = Vector2(64,64)
export var champion_icon_margins : Vector2 = Vector2(32,32)
export var champion_icon_spacing : Vector2 = Vector2(16,16)
export var select_extents_side : float = 8
export var select_extents_up : float = 8
export var select_extents_down : float = 24

var champion_array : Array = []

var hovered : String
var selected : String

var locked_in : bool = false

func _ready():
	for champion_name in Game.all_champions:
		if champion_name == "none": continue
		champion_array.append(champion_name)
	update()
	
func _process(delta):
	if locked_in: return
	var i : int = 0
	var columns = int(rect_size.x-champion_icon_margins.x*2+champion_icon_spacing.x)/int(champion_icon_size.x+champion_icon_spacing.x)
	var new_hovered = ""
	for champion_name in champion_array:
		var x = champion_icon_margins.x+(champion_icon_size.x+champion_icon_spacing.x)*(i%columns) - select_extents_side
		var y = champion_icon_margins.y+(champion_icon_size.y+champion_icon_spacing.y)*(i/columns) - select_extents_up
		var rect = Rect2(rect_global_position+Vector2(x,y),champion_icon_size+Vector2(select_extents_side*2,select_extents_up + select_extents_down))
		if rect.has_point(get_viewport().get_mouse_position()):
			new_hovered = champion_name
			if Input.is_action_just_pressed("lmb") and champion_name != selected:
				selected = champion_name
				emit_signal("selected_champion",champion_name)
				update()
			break
		i += 1
	if new_hovered != hovered:
		emit_signal("hovered_champion",new_hovered)
		hovered = new_hovered
		update()

func _draw():
	var i : int = 0
	var columns = int(rect_size.x-champion_icon_margins.x*2+champion_icon_spacing.x)/int(champion_icon_size.x+champion_icon_spacing.x)
	for champion_name in champion_array:
		var x = champion_icon_margins.x+(champion_icon_size.x+champion_icon_spacing.x)*(i%columns)
		var y = champion_icon_margins.y+(champion_icon_size.y+champion_icon_spacing.y)*(i/columns)
		draw_champion(champion_name,Vector2(x,y))
		i += 1
	if locked_in:
		draw_rect(Rect2(0,0,rect_size.x,rect_size.y),Color(0,0,0,0.8),true)

func draw_champion(champion_name,position):
	position -= Vector2(select_extents_side,select_extents_up)
	var hover_rect = Rect2(position,champion_icon_size+Vector2(select_extents_side*2,select_extents_down+select_extents_up)) 
	position += Vector2(select_extents_side,select_extents_up)
	if champion_name == selected:
		draw_rect(hover_rect,Color(1,1,1,0.5),true)
	elif champion_name ==  hovered:
		draw_rect(hover_rect,Color(1,1,1,0.2),true)
	var tex = Game.all_champions[champion_name]
	var rect = Rect2(position,champion_icon_size)
	draw_texture_rect(tex,rect,false)
	var string_size = get_font("").get_string_size(champion_name)
	var pos = position + (champion_icon_size.x/2 - string_size.x/2)*Vector2(1,0)
	pos.y += champion_icon_size.y + string_size.y/2
	draw_string(get_font(""),pos,champion_name)

func search_champion_by_name(champion_name):
	var results = []
	var regex = RegEx.new()
	regex.compile(champion_name.to_lower())
	for champion in Game.all_champions:
		if regex.search(champion.to_lower()):
			results.append(champion)
	return results
	



func _on_search(search_query):
	champion_array = search_champion_by_name(search_query)
	update()


func _on_Potvrdi_pressed():
	locked_in = true
	if selected != "" and selected != null:
		emit_signal("locked_in",selected)
	update()
