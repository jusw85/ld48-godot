class TileInfo:
	var grid_pos: Vector2
	var tile_id: int
	var autotile_id: Vector2

	func _init(p_grid_pos: Vector2, p_tile_id: int, p_autotile_id = Vector2(0.0, 0.0)) -> void:
		self.grid_pos = p_grid_pos
		self.tile_id = p_tile_id
		self.autotile_id = p_autotile_id


static func global_pos_to_tileinfo(p_tilemap: TileMap, p_global_pos: Vector2) -> TileInfo:
	var local_pos := p_tilemap.to_local(p_global_pos)
	var grid_pos := p_tilemap.world_to_map(local_pos)
	var tile_id := p_tilemap.get_cellv(grid_pos)
	var autotile_id := p_tilemap.get_cell_autotile_coord(int(grid_pos.x), int(grid_pos.y))

	return TileInfo.new(grid_pos, tile_id, autotile_id)

static func calculate_map_bounds(p_tilemap: TileMap) -> Array:
	var used_cells = p_tilemap.get_used_cells()
	if used_cells.empty():
		return []
	var cell_min := Vector2.INF
	var cell_max := -Vector2.INF
	for cell in used_cells:
		if cell.x < cell_min.x:
			cell_min.x = cell.x
		elif cell.x > cell_max.x:
			cell_max.x = cell.x
		if cell.y < cell_min.y:
			cell_min.y = cell.y
		elif cell.y > cell_max.y:
			cell_max.y = cell.y
	var bounds_min = p_tilemap.to_global(p_tilemap.map_to_world(cell_min))
	var bounds_max = p_tilemap.to_global(p_tilemap.map_to_world(cell_max))
	bounds_max += p_tilemap.cell_size
	return [cell_min, cell_max, bounds_min, bounds_max]

static func copy_tilemap(p_from: TileMap, p_from_rect: Rect2, p_y: int, p_x: int, p_to: TileMap) -> void:
	for i in range(p_from_rect.position.y, p_from_rect.position.y + p_from_rect.size.y):
		for j in range(p_from_rect.position.x, p_from_rect.position.x + p_from_rect.size.x):
			var tile_id = p_from.get_cell(j, i)
			var autotile_id = p_from.get_cell_autotile_coord(j, i)
			p_to.set_cell(p_x + j, p_y + i, tile_id, false, false, false, autotile_id)
