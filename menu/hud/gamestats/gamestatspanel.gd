extends Panel
onready var p = get_node("../../../..")

const offset : float = 8.0


func _process(delta):
	update()

func _draw():
	var time = "%02d:%02d" % [int(Game.game_time)/60,int(Game.game_time)%60]
	var x = rect_size.x - get_font("").get_string_size(time).x - offset
	var y = rect_size.y/2.0 + get_font("").get_string_size(time).y/4
	var pos = Vector2(x,y)
	draw_string(get_font(""),pos,time)
	var score = "%d/%d/%d" % [p.kills,p.deaths,p.assists]
	x = rect_size.x/2 - get_font("").get_string_size(score).x/2
	pos = Vector2(x,y)
	draw_string(get_font(""),pos,score)
	var cs = "32"#"%d/%d/%d" % [p.kills,p.deaths,p.assists]
	x = rect_size.x*0.75 - get_font("").get_string_size(score).x*0.60
	pos = Vector2(x,y)
	draw_string(get_font(""),pos,cs)
