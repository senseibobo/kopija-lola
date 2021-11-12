extends Control

var players := []
var minions := []
var turrets := []
var draw_path := []

var camera_following_mouse : bool = false
var mouse_pos : Vector2
var turret_icon : Texture = preload("res://menu/hud/minimap/turreticon.png")
var player

func _ready():
	Game.minimap = self
	for player in Game.minimap_players:
		instantiate_player_icon(player)
	for minion in Game.minimap_minions:
		instantiate_minion_icon(minion)
	for turret in Game.minimap_turrets:
		instantiate_turret_icon(turret)
	var timer : Timer = Timer.new()
	timer.autostart = false
	timer.one_shot = false
	add_child(timer)
	timer.connect("timeout",self,"update")
	timer.start(0.05)

func instantiate_player_icon(player_instance):
	players.append(player_instance)
func instantiate_minion_icon(minion_instance):
	minions.append(minion_instance)
	minion_instance.connect("death",self,"remove_minion",[minion_instance])
func instantiate_turret_icon(turret_instance):
	turrets.append(turret_instance)
	turret_instance.connect("death",self,"remove_turret",[turret_instance])

func remove_turret(turret_instance):
	turrets.erase(turret_instance)
func remove_minion(minion_instance):
	minions.erase(minion_instance)

func _draw():
	for inst in players:
		if not inst.visible: continue
		var size = Vector2(32,32)
		var position = inst.global_position/5000*500+Vector2(25,25)-size/2
		var rect = Rect2(position,size)
		draw_texture_rect(inst.sprite.texture,rect,false)
	for inst in minions:
		if not inst.visible: continue
		draw_circle(inst.global_position/5000*500+Vector2(25,25),3,[Color.red,Color.blue][int(Lobby.my_team == inst.team)])
	for inst in turrets:
		var size = turret_icon.get_size()
		var position = inst.global_position/5000*500+Vector2(25,25)-size/2
		draw_texture(turret_icon,position,[Color.red,Color.blue][int(Lobby.my_team == inst.team)])
	for i in range(0,player.path.size()):
		if i == 0:
			draw_line(player.global_position/10.0+Vector2(25,25),player.path[0]/10.0+Vector2(25,25),Color.white)
		else:
			draw_line(player.path[i-1]/10.0+Vector2(25,25),player.path[i]/10.0+Vector2(25,25),Color.white)
			
func _process(delta):
	if camera_following_mouse:
		get_tree().current_scene.get_node("WorldCamera").global_position = mouse_pos*10.0

func _on_map_gui_input(event : InputEvent):
	if event.is_action_pressed("lmb"):
		camera_following_mouse = true
	elif event.is_action_released("lmb"):
		camera_following_mouse = false
	if event.is_action_pressed("rmb"):
		Game.get_player_node().get_node(str(get_tree().get_network_unique_id())).move_champion(mouse_pos*10,false)
	if event is InputEventMouseMotion:
		mouse_pos = event.position
		
