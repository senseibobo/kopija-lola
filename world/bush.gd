extends Polygon2D

class_name Bush

var area : Area2D
var occluder : LightOccluder2D
var collisionpolygon : CollisionPolygon2D
var revealed : Array = [0,0]


func _ready():
	area = Area2D.new()
	area.collision_mask = 64
	area.collision_layer = 4
	occluder = LightOccluder2D.new()
	occluder.occluder = OccluderPolygon2D.new()
	occluder.occluder.polygon = self.polygon
	collisionpolygon = CollisionPolygon2D.new()
	collisionpolygon.polygon = self.polygon
	add_child(occluder)
	texture = preload("res://world/bush.png")
	add_child(area)
	area.add_child(collisionpolygon)

func _physics_process(delta):
	var team_players = 0
	revealed = [0,0]
	area.collision_layer = 48
	modulate.a = 1
	var cell_coords = Optimizations.get_cell_coords((polygon[0]+polygon[polygon.size()/2])/2.0)
	for entity in Optimizations.get_entities_around_cell(cell_coords,Lobby.my_team,false,Optimizations.get_min_cell_radius(300)):
		if Geometry.is_point_in_polygon(entity.global_position,polygon): 
			team_players = 1
			revealed[entity.team] = 1
			area.set_collision_layer_bit(4 + entity.team, false)
			modulate.a = 0.5
	occluder.light_mask = 1-team_players
	
