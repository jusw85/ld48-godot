extends Node2D


onready var tilemap: TileMap = $TileMap
onready var border: TileMap = $Border
onready var soil: TileMap = $Soil

var bounds_min := Vector2(INF, INF)
var bounds_max := Vector2(-INF, -INF)

var gen_depth := 0
var gen_bottom := 0
var gen_buffer := 7
var gen_range := 10

const Fuel := preload("res://collectibles/fuel.tscn")
const Gem := preload("res://collectibles/gem.tscn")

# fuel, gem, empty, stone(rest)
# last val computed
var tile_prob = [
	[0.07, 0.02, 0.20, 0.71]
]

var stone_prob = [
	[0.90, 0.10, 0.00, 0.00], \
	[0.80, 0.15, 0.05, 0.00], \
	[0.75, 0.15, 0.05, 0.05], \
	[0.65, 0.20, 0.10, 0.05], \
	[0.50, 0.30, 0.10, 0.10], \
	[0.30, 0.40, 0.15, 0.15], \
]

# feature: create premade vaults
func _ready():
	randomize()
	_create_map()
	_calculate_map_bounds()
#	_replace_map_tiles_with_objects()


func _calculate_map_bounds():
	var used_cells = tilemap.get_used_cells()
	for pos in used_cells:
		if pos.x < bounds_min.x:
			bounds_min.x = int(pos.x)
		elif pos.x > bounds_max.x:
			bounds_max.x = int(pos.x)
		if pos.y < bounds_min.y:
			bounds_min.y = int(pos.y)
		elif pos.y > bounds_max.y:
			bounds_max.y = int(pos.y)


# 6 down view range
# 15 across x 10 = 150 tiles
# fuel: 0
# gem: 1
# rocks: 4 - 1, 3, 5 ,7
# gen_depth: 0,4,14,24,34,...
# gen_depth normalized: 1,2,3,4
# gem / fuel / emptytiles / stone
func _create_map():
	var total_tiles = gen_range * 15
	for y in range(gen_bottom, gen_bottom + gen_range):
		for x in range(0, 15):
			var p = randf()
			var idx = gen_depth
			if gen_depth >= tile_prob.size():
				idx = tile_prob.size() - 1
			if p < tile_prob[idx][0]:
				_create_fuel(x, y)
			elif p < tile_prob[idx][0] + tile_prob[idx][1]:
				_create_gem(x, y)
			elif p < tile_prob[idx][0] + tile_prob[idx][1] + tile_prob[idx][2]:
				pass
			else:
				p = randf()
				idx = gen_depth
				if gen_depth >= stone_prob.size():
					idx = stone_prob.size() - 1
				if p < stone_prob[idx][0]:
					tilemap.set_cell(x, y, \
						4, false, false, false, Vector2(1, 0))
				elif p < stone_prob[idx][0] + stone_prob[idx][1]:
					tilemap.set_cell(x, y, \
						4, false, false, false, Vector2(3, 0))
				elif p < stone_prob[idx][0] + stone_prob[idx][1] + stone_prob[idx][2]:
					tilemap.set_cell(x, y, \
						4, false, false, false, Vector2(5, 0))
				else:
					tilemap.set_cell(x, y, \
						4, false, false, false, Vector2(7, 0))

			soil.set_cell(x, y, \
				4, false, false, false, Vector2(0, 0))

	for y in range(gen_bottom, gen_bottom + gen_range):
		border.set_cell(-1, y, \
			4, false, false, false, Vector2(8, 0))
		border.set_cell(15, y, \
			4, false, false, false, Vector2(8, 0))

	gen_bottom = gen_bottom + gen_range

func _create_gem(x: int, y: int):
	var instance = Gem.instance()
	_create_instance(instance, x, y)

func _create_fuel(x: int, y: int):
	var instance = Fuel.instance()
	_create_instance(instance, x, y)

func _create_instance(instance: Node, x: int, y: int):
	add_child(instance)
	var local_pos = tilemap.map_to_world(Vector2(x, y))
	instance.position = local_pos


# first = range - buffer + 1
# step = range
func check_create_map(depth: int):
	if depth > gen_bottom - gen_buffer:
		depth =  (depth + gen_buffer - 1) / gen_range
		gen_depth = depth
		_create_map()

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
