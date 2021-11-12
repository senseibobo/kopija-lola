extends Node2D

var entity_locations = {}
var entity_grid = [[],[],[]]
const CELL_SIZE : float = 100.0
onready var grid_size = Vector2(ceil(5000/CELL_SIZE),ceil(5000/CELL_SIZE))

func _ready():
	for team in range(3):
		for i in grid_size.x:
			entity_grid[team].append([])
			for j in grid_size.y:
				entity_grid[team][i].append([])

func get_cell_coords(point : Vector2):
	return Vector2(int(point.x/CELL_SIZE),int(point.y/CELL_SIZE))

func get_min_cell_radius(_range : float):
	return int(_range/CELL_SIZE)+1

func update_entity(entity, new_coords : Vector2):
	if entity_locations.has(entity):
		var c = entity_locations[entity]
		entity_grid[entity.team][c.x][c.y].erase(entity)
	entity_locations[entity] = new_coords
	entity_grid[entity.team][new_coords.x][new_coords.y].append(entity)

func remove_entity(entity):
	if entity_locations.has(entity):
		var c = entity_locations[entity]
		entity_grid[entity.team][c.x][c.y].erase(entity)
		entity_locations.erase(entity)
	
func get_entities_around_cell(cell_coords : Vector2,team : int = -1,not_team : bool = false,radius : int = 2):
	var entities = []
	for j in range(max(0,cell_coords.y-radius),min(grid_size.y,cell_coords.y+radius+1)):
		for i in range(max(0,cell_coords.x-radius),min(grid_size.x,cell_coords.x+radius+1)):
			if team == -1:
				for t in range(3):
					entities.append_array(entity_grid[t][i][j])
			else:
				if not_team:
					for t in range(3):
						if t != team:
							entities.append_array(entity_grid[t][i][j])
				else:
					entities.append_array(entity_grid[team][i][j])
	return entities

func collision_slide(e):
	if e.ghosting > 0: return
	var entities = get_entities_around_cell(e.grid_coords,-1,1)
	for entity in entities:
		if not is_instance_valid(entity): continue
		if entity.ghosting > 0: continue
		var entity_pos = entity.global_position
		var entity_col = entity.collision_radius
		var dist = e.global_position.distance_to(entity_pos)
		if dist < max(e.collision_radius,entity_col):
			e.global_position = e.global_position.move_toward(entity_pos,dist-max(entity_col,e.collision_radius))


func check_collision(e,team : int = -1,not_team : bool = false):
	var e_coords : Vector2
	e_coords.x = floor(e.global_position.x/CELL_SIZE)
	e_coords.y = floor(e.global_position.y/CELL_SIZE)
	var colliders = []
	for entity in get_entities_around_cell(e_coords,team,not_team,1):
		if check_collision_with_entity(e,entity):
			colliders.append(entity)
	return colliders

func check_collision_gameplay(e,team : int = -1, not_team : bool = false):
	var e_coords : Vector2
	e_coords.x = floor(e.global_position.x/CELL_SIZE)
	e_coords.y = floor(e.global_position.y/CELL_SIZE)
	var colliders = []
	for entity in get_entities_around_cell(e_coords,team,not_team,1):
		if check_collision_gameplay_with_entity(e,entity):
			colliders.append(entity)
	return colliders
	
func check_collision_with_entity(e,entity):
	var entity_pos = entity.global_position
	var entity_col = entity.collision_radius
	var dist = e.global_position.distance_squared_to(entity_pos)
	if dist < pow(max(e.collision_radius,entity_col),2):
		return true
	return false

func check_collision_gameplay_with_entity(e,entity):
	var entity_pos = entity.global_position
	var entity_col = entity.gameplay_radius
	var dist = e.global_position.distance_squared_to(entity_pos)
	if dist < pow(abs(e.gameplay_radius)+abs(entity_col),2):
		return true
	return false
