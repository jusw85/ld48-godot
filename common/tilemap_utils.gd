class TileInfo:
	var grid_pos: Vector2
	var tile_id: int
	var autotile_id: Vector2

	func _init(p_grid_pos: Vector2, p_tile_id: int,
			p_autotile_id = Vector2(0.0, 0.0)) -> void:
		self.grid_pos = p_grid_pos
		self.tile_id = p_tile_id
		self.autotile_id = p_autotile_id


static func global_pos_to_tileinfo(p_tilemap: TileMap, p_global_pos: Vector2) -> TileInfo:
	var local_pos = p_tilemap.to_local(p_global_pos)
	var grid_pos := p_tilemap.world_to_map(local_pos)
	var tile_id := p_tilemap.get_cellv(grid_pos)
	var autotile_id := p_tilemap.get_cell_autotile_coord(int(grid_pos.x), int(grid_pos.y))

	return TileInfo.new(grid_pos, tile_id, autotile_id)
