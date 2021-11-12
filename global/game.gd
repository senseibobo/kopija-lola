extends Node

enum CHAMPIONS {
	MARIN,
	KOSA,
	MILICA,
	SRECKO
}

var camera

var hovered_enemy
var hovered_ally
var current_number : int = 0 setget set_current_number,get_current_number

var minimap_players = []
var minimap_minions = []
var minimap_turrets = []
var minimap = null
var all_items : Dictionary = {}
const all_champions : Dictionary = {
	"Marin" : preload("res://champions/marin/marin.png"),
	"Kosa" : preload("res://champions/kosa/kosa.png"),
	"Milica" : preload("res://champions/milica/milica.png"),
	"Srecko" : preload("res://champions/srecko/srecko.png"),
	"Vladimir" : preload("res://champions/vladimir/vladimir.png"),
	"none" : null
}

var game_time : float = 0.0

var hud : HUD = null

func _process(delta):
	if Lobby.game_started:
		game_time += delta

func _ready():
	load_items()
	
func load_items():
	var dir = Directory.new()
	dir.open("res://items")
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "": break
		if file.ends_with(".gd") or file.ends_with(".gdc"):
			var item = load(dir.get_current_dir() + "/" + file).new()
			all_items[item.id] = item

func instantiate_turret_icon(turret):
	if minimap != null:
		minimap.instantiate_turret_icon(turret)
	else:
		minimap_turrets.append(turret)
func instantiate_player_icon(player):
	if minimap != null:
		minimap.instantiate_player_icon(player)
	else:
		minimap_players.append(player)
func instantiate_minion_icon(minion):
	if minimap != null:
		minimap.instantiate_minion_icon(minion)
	else:
		minimap_minions.append(minion)
func get_visual_effects_node():
	return get_tree().current_scene.get_node("VisualEffects")

func set_current_number(value):
	current_number = value

func get_current_number():
	current_number += 1
	return current_number

func get_projectile_node():
	return get_tree().current_scene.get_node("Projectiles")

func get_player_node():
	return get_tree().current_scene.get_node("Entities/Players")

func get_players(team : int = -1,not_team : bool = false, revealed_only : bool = false):
	var all_players = get_player_node().get_children()
	if team == -1: return all_players
	var players = []
	for player in all_players:
		if not not_team and player.team == team and (not revealed_only or player.revealed_to & (team+1) != 0):
			players.append(player)
		elif not_team and player.team != team and (not revealed_only or player.revealed_to & (team+1) != 0):
			players.append(player)
	return players

func get_minion_node():
	return get_tree().current_scene.get_node("Entities/Minions")

func get_minions(team : int = -1, not_team : bool = false, revealed_only : bool = false):
	var all_minions = get_minion_node().get_children()
	if team == -1: return all_minions
	var minions = []
	for minion in all_minions:
		if not not_team and minion.team == team and (not revealed_only or minion.revealed_to & (team+1) != 0):
			minions.append(minion)
		elif not_team and minion.team != team and (not revealed_only or minion.revealed_to & (team+1) != 0):
			minions.append(minion)
	return minions

func get_nearest_minion(point : Vector2, team : int = -1, not_team : bool = false, revealed_only : bool = true):
	var minions = get_minions(team, not_team, revealed_only)
	return get_nearest_in_array(point, minions)
	

func get_pentity_node():
	return get_tree().current_scene.get_node("Entities/PlayerEntities")
	
func get_monster_node():
	return get_tree().current_scene.get_node("Entities/Tetkice")

func get_pentities(team : int = -1, not_team : bool = false, revealed_only : bool = false):
	var all_pentities = get_pentity_node().get_children()
	if team == -1: return all_pentities
	var pentities = []
	for pentity in all_pentities:
		if not not_team and pentity.team == team and (not revealed_only or pentity.revealed_to & (team+1) != 0):
			pentities.append(pentity)
		if not_team and pentity.team != team and (not revealed_only or pentity.revealed_to & (team+1) != 0):
			pentities.append(pentity)
	return pentities

func get_monsters(team : int = -1, not_team : bool = false, revealed_only : bool = false):
	var all_monsters = get_monster_node().get_children()
	if team == -1: return all_monsters
	var monsters = []
	for monster in all_monsters:
		if not not_team and monster.team == team and (not revealed_only or monster.revealed_to & (team+1) != 0):
			monsters.append(monster)
		if not_team and monster.team != team and (not revealed_only or monster.revealed_to & (team+1) != 0):
			monsters.append(monster)
	return monsters

func get_entities(team : int = -1, not_team : bool = false, revealed_only : bool = false):
	var entities = []
	entities.append_array(get_turrets(team,not_team))
	entities.append_array(get_players(team,not_team,revealed_only))
	entities.append_array(get_minions(team,not_team,revealed_only))
	entities.append_array(get_monsters(team,not_team,revealed_only))
	entities.append_array(get_pentities(team,not_team,revealed_only))
	return entities

func get_navigation_path(from,to):
	var nav = get_tree().current_scene.get_node("Navigation2D") as Navigation2D
	return nav.get_simple_path(from,to)

func get_closest_point_to(point):
	var nav = get_tree().current_scene.get_node("Navigation2D") as Navigation2D
	return nav.get_closest_point(point)

func get_nearest_entity(point : Vector2, team : int = -1, not_team : bool = false, revealed_only : bool = true):
	var entities = get_entities(team,not_team,revealed_only)
	var nearest = null
	for entity_index in range(0,entities.size()):
		if revealed_only and not entities[entity_index].revealed_to & (team+1) != 0: continue
		if nearest == null or point.distance_squared_to(entities[entity_index].global_position) < point.distance_squared_to(nearest.global_position):
			nearest = entities[entity_index]
	return nearest

func get_entities_in_range(point : Vector2, _range : float, team : int = -1, not_team : bool = false, revealed_only : bool = false):
	#var entities = get_entities(team,not_team)
	var grid_coords = Optimizations.get_cell_coords(point)
	var entities = Optimizations.get_entities_around_cell(grid_coords,team,not_team,Optimizations.get_min_cell_radius(_range))
	var entities_in_range = []
	for entity in entities:
		var revelation = not revealed_only or entity.revealed_to & (team+1) != 0
		var distance = point.distance_squared_to(entity.global_position) <= _range*_range
		if distance and revelation and entity.targetable >= 1 and not entity.dead: entities_in_range.append(entity)
	entities_in_range = sort_by_distance(point,entities_in_range)
	return entities_in_range
	
func is_entity_in_range(entity, point : Vector2, _range : float):
	if point.distance_squared_to(entity.global_position) <= _range*_range and entity.targetable >= 1: return true
	return false

func get_turrets(team : int = -1, not_team : bool = false):
	var all_turrets = get_turrent_node().get_children()
	if team == -1: return all_turrets
	var turrets = []
	for turret in all_turrets:
		if not not_team and turret.team == team:
			turrets.append(turret)
		elif not_team and turret.team != team:
			turrets.append(turret)
	return turrets

func get_turrent_node():
	return get_tree().current_scene.get_node("Entities/Turrets")

func get_turrets_in_range(point : Vector2, _range : float, team : int = -1, not_team : bool = false):
	var turrets = get_turrets(team,not_team)
	var turrets_in_range = []
	for turret in turrets:
		if point.distance_squared_to(turret.global_position) <= _range*_range and turret.targetable >= 1: turrets_in_range.append(turret)
	turrets_in_range = sort_by_distance(point,turrets_in_range)
	return turrets_in_range

func get_nearest_turret(point : Vector2):
	return get_nearest_in_array(point,get_turrets())

func get_pentities_in_range(point : Vector2, _range : float, team : int = -1, not_team : bool = false):
	var pentities = get_pentities(team,not_team)
	var pentities_in_range = []
	for pentity in pentities:
		if point.distance_squared_to(pentity.global_position) <= _range*_range and pentity.targetable >= 1: pentities_in_range.append(pentity)
	pentities_in_range = sort_by_distance(point,pentities_in_range)
	return pentities_in_range

func sort_by_distance(point : Vector2, array : Array, descending : bool = false) -> Array:
	for i in array.size()-1:
		for j in range(i+1,array.size()):
			if descending: 
				if array[i].global_position.distance_squared_to(point) < array[j].global_position.distance_squared_to(point):
					var p = array[i]
					array[i] = array[j]
					array[j] = p
			else:
				if array[i].global_position.distance_squared_to(point) > array[j].global_position.distance_squared_to(point):
					var p = array[i]
					array[i] = array[j]
					array[j] = p
	return array

func get_minions_in_range(point : Vector2, _range : float, team : int = -1, not_team : bool = false):
	var minions = get_minions(team, not_team)
	var minions_in_range = []
	for minion in minions:
		if point.distance_squared_to(minion.global_position) <= _range*_range and minion.targetable >= 1: minions_in_range.append(minion)
	minions_in_range = sort_by_distance(point,minions_in_range)
	return minions_in_range

func get_nearest_in_array(point : Vector2, array : Array):
	var nearest = null
	var nearest_distance : float = 0.0
	for entity in array:
		var dist = entity.global_position.distance_squared_to(point)
		if nearest == null or dist < nearest_distance:
			nearest_distance = dist
			nearest = entity
	return nearest

func get_nearest_player(point : Vector2, team : int = -1, not_team : bool = false, revealed_only : bool = true):
	var players = get_players(team, not_team)
	var nearest = null
	for player_index in range(0,players.size()):
		if revealed_only and not players[player_index].revealed_to & (team+1) != 0 or players[player_index].targetable < 1: continue
		if nearest == null or point.distance_squared_to(players[player_index].global_position) < point.distance_to(nearest.global_position):
			nearest = players[player_index]
	return nearest

func get_players_in_range(point : Vector2, radius : float, team : int = -1, not_team : bool = false):
	var players = get_players(team, not_team)
	var players_in_range = []
	for player in players:
		if point.distance_to(player.global_position) <= radius and player.targetable >= 1: players_in_range.append(player)
	players_in_range = sort_by_distance(point,players_in_range)
	return players_in_range

func get_players_in_cone(point : Vector2, radius : float, dir : Vector2, angle : float, team : int = -1, not_team : bool = false):
	var players = get_players_in_range(point,radius,team,not_team)
	var players_in_cone = []
	for player in players:
		if abs(point.angle_to_point(point)-Vector2().angle_to_point(dir)) <= deg2rad(angle)/2:
			players_in_cone.append(player)
	return players_in_cone

func get_entities_in_cone(point : Vector2, radius : float, dir : Vector2, angle : float, team : int = -1, not_team : bool = false):
	var entities = get_entities_in_range(point,radius,team, not_team)
	var entities_in_cone = []
	for entity in entities:
		if abs(point.angle_to_point(entity.global_position)-dir.angle()) <= deg2rad(angle/2):
			entities_in_cone.append(entity)
	return entities_in_cone



		
func add_dictionaries(dict1 : Dictionary, dict2 : Dictionary) -> Dictionary:
	var new_dict := dict1
	for key in dict2:
		if not new_dict.has(key):
			new_dict[key] = dict2[key]
	return new_dict
	
func tween_property(object,property,start_value,final_value,duration):
	var tween = Tween.new()
	tween.connect("tween_completed",tween,"queue_free")
	add_child(tween)
	tween.interpolate_property(object,property,start_value,final_value,duration,Tween.TRANS_SINE,Tween.EASE_IN_OUT)


func _input(event):
	if event.is_action_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
