extends Node

var grid: AStarGrid2D
var _map_layer: TileMapLayer

## Called by the level manager to construct the nav grid
func initialize_grid(tilemap_layer: TileMapLayer, map_size: Rect2i) -> void:
	_map_layer = tilemap_layer
	
	grid = AStarGrid2D.new()
	grid.region = map_size
	grid.cell_size = tilemap_layer.tile_set.tile_size
	grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	grid.update()
	
	_bake_grid(tilemap_layer, map_size)

func _bake_grid(layer: TileMapLayer, map_size: Rect2i) -> void:
	# Step 1: Extract solid obstacles from tileset physics
	for x in range(map_size.position.x, map_size.end.x):
		for y in range(map_size.position.y, map_size.end.y):
			var coords = Vector2i(x, y)
			var tile_data = layer.get_cell_tile_data(coords)
			if tile_data and tile_data.get_collision_polygons_count(0) > 0:
				grid.set_point_solid(coords, true)
				
	# Step 2: Inflate obstacles downward for 1x2 entity head room clearance
	for x in range(map_size.position.x, map_size.end.x):
		for y in range(map_size.position.y, map_size.end.y):
			var coords = Vector2i(x, y)
			if grid.is_point_solid(coords):
				var cell_below = coords + Vector2i(0, 1)
				if grid.region.has_point(cell_below):
					grid.set_point_solid(cell_below, true)

func get_pixel_path(start_pos: Vector2, end_pos: Vector2) -> Array[Vector2]:
	if not grid or not _map_layer:
		return []
		
	var start_cell: Vector2i = _map_layer.local_to_map(start_pos)
	var end_cell: Vector2i = _map_layer.local_to_map(end_pos)
	
	if not grid.region.has_point(start_cell) or not grid.region.has_point(end_cell):
		return []
	
	if grid.is_point_solid(end_cell):
		end_cell = _get_closest_walkable_cell(end_cell)
		
	var id_path: Array[Vector2i] = grid.get_id_path(start_cell, end_cell)
	
	var pixel_path: Array[Vector2] = []
	for cell in id_path:
		pixel_path.append(_map_layer.map_to_local(cell))
		
	return pixel_path

func _get_closest_walkable_cell(target: Vector2i) -> Vector2i:
	var directions = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
	for dir in directions:
		var check = target + dir
		if grid.region.has_point(check) and not grid.is_point_solid(check):
			return check
	return target
