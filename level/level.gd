# warning-ignore-all:return_value_discarded
extends Node2D

const Fuel := preload("res://collectibles/fuel.tscn")
const Gem := preload("res://collectibles/gem.tscn")
const Rock := preload("res://level/objects/rock.tscn")
const Spike := preload("res://level/objects/spike.tscn")
const Premades = [
	preload("res://level/premade/spiketrap.tscn"),
	preload("res://level/premade/vault1.tscn"),
	preload("res://level/premade/vault2.tscn"),
	preload("res://level/premade/hell.tscn"),
]

# https://github.com/godotengine/godot/issues/33095
# Also save _rng.state from randomize() for reproducible streams
export var use_seed := false
export var rng_seed := 0
export var map_width := 15

var bottom := 1
var bounds_min := Vector2(INF, INF)
var bounds_max := Vector2(-INF, -INF)

var _rng: RandomNumberGenerator
var _premade_instances = []
var _premade_tilemaps = []
var _premade_rects = []

onready var tilemap: TileMap = $TileMap
onready var soil: TileMap = $Soil


func _ready():
	_init_rng()

	for premade in Premades:
		var inst = premade.instance()
		var inst_tilemap = inst.get_node("TileMap")
		var inst_rect = inst_tilemap.get_used_rect()

		_premade_instances.append(inst)
		_premade_tilemaps.append(inst_tilemap)
		_premade_rects.append(inst_rect)

	var res = NC.TileMapUtils.calculate_map_bounds(tilemap)
	bounds_min = res[2]
	bounds_max = res[3]


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		for premade in _premade_instances:
			premade.queue_free()


func get_grid_pos(p_global_pos: Vector2) -> Vector2:
	var local_pos = tilemap.to_local(p_global_pos)
	return tilemap.world_to_map(local_pos)


func create_rows(p_num_rows: int, p_difficulty: int):
	var i
	i = int(clamp(p_difficulty, 0, Globals.tile_probability.size() - 1))
	var tile_probability = Globals.tile_probability[i]
	i = int(clamp(p_difficulty, 0, Globals.rock_probability.size() - 1))
	var rock_probability = Globals.rock_probability[i]

	# draw border and soil
	for y in range(bottom, bottom + p_num_rows):
		_draw_border(y)
		for x in range(map_width):
			_draw_soil(y, x)

	# draw tiles
	for y in range(bottom, bottom + p_num_rows):
		var x = 0
		while x < map_width:
			if _try_create_cell(y, x, tile_probability, rock_probability):
				x += 1

	# convert to object
	for y in range(bottom, bottom + p_num_rows):
		for x in range(0, map_width):
			_convert_tile_to_object(y, x)

	bottom = bottom + p_num_rows


func create_hell():
	var hell_tilemap = _premade_tilemaps[3]
	var hell_rect = _premade_rects[3]
	var hell_inst = _premade_instances[3]

	NC.TileMapUtils.copy_tilemap(hell_tilemap, hell_rect, bottom, 0, tilemap)
	hell_inst.remove_child(hell_tilemap)
	_add_node(bottom, 0, hell_inst, false)

	for y in range(bottom, bottom + hell_rect.size.y + 15):
		_draw_border(y)
		for x in range(0, map_width):
			_draw_soil(y, x)
			var node = _convert_tile_to_object(y, x)
			if node != null and node.is_in_group("spike"):
				node.dmg = 30


func _convert_tile_to_object(y: int, x: int) -> Node:
	var node = null
	match tilemap.get_cell(x, y):
		0:
			tilemap.set_cell(x, y, TileMap.INVALID_CELL)
			node = Fuel.instance()
			_add_node(y, x, node)
		1:
			tilemap.set_cell(x, y, TileMap.INVALID_CELL)
			node = Gem.instance()
			_add_node(y, x, node)
		4:
			var autotile_id = int(tilemap.get_cell_autotile_coord(x, y).x)
			if autotile_id >= 1 and autotile_id <= 7:
				tilemap.set_cell(x, y, TileMap.INVALID_CELL)
				node = Rock.instance()
				_add_node(y, x, node)
				node.init(autotile_id)
		6:
			tilemap.set_cell(x, y, TileMap.INVALID_CELL)
			node = Spike.instance()
			_add_node(y, x, node)
	return node


func _try_create_cell(p_y: int, p_x: int, p_tile_probability: Array, p_rock_probability: Array) -> bool:
	var cell = tilemap.get_cell(p_x, p_y)
	if cell == 8:
		tilemap.set_cell(p_x, p_y, TileMap.INVALID_CELL)
	elif cell == 9:
		_draw_random_rock(p_y, p_x, p_rock_probability)
	elif cell == TileMap.INVALID_CELL:
		match _get_idx_from_intervals(_rng.randf(), p_tile_probability):
			0:
				tilemap.set_cell(p_x, p_y, 0)
			1:
				tilemap.set_cell(p_x, p_y, 1)
			2:
				pass
			3:
				if _can_spawn_premade(p_y, p_x, _premade_rects[0]):
					NC.TileMapUtils.copy_tilemap(
						_premade_tilemaps[0], _premade_rects[0], p_y, p_x, tilemap
					)
					return false
				else:
					_draw_random_rock(p_y, p_x, p_rock_probability)
			4:
				if _can_spawn_premade(p_y, p_x, _premade_rects[1]):
					NC.TileMapUtils.copy_tilemap(
						_premade_tilemaps[1], _premade_rects[1], p_y, p_x, tilemap
					)
					return false
				else:
					_draw_random_rock(p_y, p_x, p_rock_probability)
			5:
				if _can_spawn_premade(p_y, p_x, _premade_rects[2]):
					NC.TileMapUtils.copy_tilemap(
						_premade_tilemaps[2], _premade_rects[2], p_y, p_x, tilemap
					)
					return false
				else:
					_draw_random_rock(p_y, p_x, p_rock_probability)
			_:
				_draw_random_rock(p_y, p_x, p_rock_probability)
	return true


func _can_spawn_premade(p_y: int, p_x: int, p_rect: Rect2) -> bool:
	if (p_x + p_rect.size.x) > map_width:
		return false
	for i in int(p_rect.size.y):
		for j in int(p_rect.size.x):
			if tilemap.get_cell(p_x + j, p_y + i) != TileMap.INVALID_CELL:
				return false
	return true


func _add_node(p_y: int, p_x: int, p_instance: Node, p_centred: bool = true):
	add_child(p_instance)
	var local_pos = tilemap.map_to_world(Vector2(p_x, p_y))
	if p_centred:
		local_pos += (tilemap.cell_size / 2.0)
	p_instance.position = local_pos


func _draw_random_rock(p_y: int, p_x: int, p_rock_probability: Array):
	var subtile_idx
	match _get_idx_from_intervals(_rng.randf(), p_rock_probability):
		0:
			subtile_idx = 1
		1:
			subtile_idx = 3
		2:
			subtile_idx = 5
		_:
			subtile_idx = 7
	tilemap.set_cell(p_x, p_y, 4, false, false, false, Vector2(subtile_idx, 0))


func _draw_soil(p_y: int, p_x: int):
	soil.set_cell(p_x, p_y, 4)


func _draw_border(p_y: int):
	tilemap.set_cell(-1, p_y, 7, false, false, false, Vector2(2, 0))
	tilemap.set_cell(map_width, p_y, 7, false, false, false, Vector2(3, 0))


func _get_idx_from_intervals(p_prob: float, p_arr: Array) -> int:
	var length = len(p_arr)
	for idx in length:
		if p_prob < p_arr[idx]:
			return idx
	return length


func _init_rng():
	_rng = RandomNumberGenerator.new()
	if use_seed:
		_rng.seed = rng_seed
	else:
		_rng.randomize()

#func _replace_map_tiles_with_objects():
#	var fuels = tilemap.get_used_cells_by_id(0)
#	for pos in fuels:
#		tilemap.set_cellv(pos, -1)
#		var instance = Fuel.instance()
#		add_child(instance)
#		var local_pos = tilemap.map_to_world(pos)
##		var global_pos = tilemap.to_global(local_pos)
#		instance.position = local_pos
#
#	var gems = tilemap.get_used_cells_by_id(1)
#	for pos in gems:
#		tilemap.set_cellv(pos, -1)
#		var instance = Gem.instance()
#		add_child(instance)
#		var local_pos = tilemap.map_to_world(pos)
##		var global_pos = tilemap.to_global(local_pos)
#		instance.position = local_pos
