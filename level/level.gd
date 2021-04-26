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
const Spike := preload("res://level/spike.tscn")

const Spike1 := preload("res://level/premade/spike1.tscn")
var spike1_tilemap
var spike1_rect

const Trap1 := preload("res://level/premade/trap1.tscn")
var trap1_tilemap
var trap1_rect

const Trap2 := preload("res://level/premade/trap2.tscn")
var trap2_tilemap
var trap2_rect

# fuel, gem, empty, spike, trap, stone(rest)
# last val is remaining, doesn't need to be correct
var tile_prob = [
	[0.09, 0.02, 0.20, 0.00, 0.00, 0.00, 0.71], \
	[0.09, 0.02, 0.20, 0.00, 0.00, 0.00, 0.61], \
	[0.09, 0.02, 0.20, 0.00, 0.00, 0.00, 0.61], \
	[0.08, 0.03, 0.20, 0.02, 0.00, 0.00, 0.61], \
	[0.08, 0.03, 0.20, 0.02, 0.00, 0.00, 0.61], \
	[0.08, 0.03, 0.20, 0.02, 0.00, 0.00, 0.61], \
	[0.07, 0.04, 0.20, 0.04, 0.01, 0.01, 0.61], \
	[0.07, 0.04, 0.20, 0.04, 0.01, 0.01, 0.61], \
	[0.07, 0.04, 0.20, 0.04, 0.01, 0.01, 0.61], \
	[0.06, 0.05, 0.20, 0.06, 0.01, 0.01, 0.61], \
	[0.06, 0.05, 0.20, 0.06, 0.01, 0.01, 0.61], \
	[0.06, 0.05, 0.20, 0.06, 0.01, 0.01, 0.61], \
	[0.06, 0.05, 0.20, 0.08, 0.01, 0.01, 0.61], \
	[0.06, 0.05, 0.20, 0.08, 0.02, 0.02, 0.61], \
	[0.06, 0.05, 0.20, 0.08, 0.02, 0.02, 0.61], \
	[0.06, 0.05, 0.20, 0.10, 0.02, 0.02, 0.61], \
]

var stone_prob = [
	[0.90, 0.10, 0.00, 0.00], \
	[0.80, 0.15, 0.05, 0.00], \
	[0.75, 0.15, 0.05, 0.05], \
	[0.65, 0.20, 0.10, 0.05], \
	[0.50, 0.30, 0.10, 0.10], \
	[0.30, 0.40, 0.15, 0.15], \
	[0.25, 0.45, 0.15, 0.15], \
	[0.20, 0.40, 0.20, 0.20], \
	[0.15, 0.30, 0.30, 0.25], \
	[0.10, 0.20, 0.40, 0.30], \
	[0.05, 0.10, 0.45, 0.40], \
	[0.05, 0.05, 0.40, 0.50], \
]

var tile_prob_cum
var stone_prob_cum

# feature: create premade vaults
func _ready():
	randomize()
	tile_prob_cum = tile_prob.duplicate(true)
	for row in tile_prob_cum:
		for x in range(1, row.size()):
			row[x] = row[x-1] + row[x]

	stone_prob_cum = stone_prob.duplicate(true)
	for row in stone_prob_cum:
		for x in range(1, row.size()):
			row[x] = row[x-1] + row[x]

#	_replace_map_tiles_with_objects()
	spike1_tilemap = Spike1.instance().get_node("TileMap")
	spike1_rect = spike1_tilemap.get_used_rect()
	trap1_tilemap = Trap1.instance().get_node("TileMap")
	trap1_rect = trap1_tilemap.get_used_rect()
	trap2_tilemap = Trap2.instance().get_node("TileMap")
	trap2_rect = trap2_tilemap.get_used_rect()

	_create_map()
	_calculate_map_bounds()


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
#	var total_tiles = gen_range * 15
	var idx = int(clamp(gen_depth, 0, tile_prob_cum.size() - 1))
	var idx2 = int(clamp(gen_depth, 0, stone_prob_cum.size() - 1))
	var cur_tile_prob = tile_prob_cum[idx]
	var cur_stone_prob = stone_prob_cum[idx2]

	for y in range(gen_bottom, gen_bottom + gen_range):
		var x = 0
		while x < 15:
			soil.set_cell(x, y, 4, false, false, false, Vector2(0, 0))
			if tilemap.get_cell(x, y) >= 0:
				x += 1
				continue

			var p = randf()
			if p < cur_tile_prob[0]:
				tilemap.set_cell(x, y, 0)
			elif p < cur_tile_prob[1]:
				tilemap.set_cell(x, y, 1)
			elif p < cur_tile_prob[2]:
				pass
			elif p < cur_tile_prob[3] and _can_spawn(spike1_rect, x, y):
				_spawn_premade(spike1_tilemap, spike1_rect, x, y)
				continue
			elif p < cur_tile_prob[4] and _can_spawn(trap1_rect, x, y):
				_spawn_premade(trap1_tilemap, trap1_rect, x, y)
				continue
			elif p < cur_tile_prob[5] and _can_spawn(trap2_rect, x, y):
				_spawn_premade(trap2_tilemap, trap2_rect, x, y)
				continue
			else:
				p = randf()
				if p < cur_stone_prob[0]:
					tilemap.set_cell(x, y, 4, false, false, false, Vector2(1, 0))
				elif p < cur_stone_prob[1]:
					tilemap.set_cell(x, y, 4, false, false, false, Vector2(3, 0))
				elif p < cur_stone_prob[2]:
					tilemap.set_cell(x, y, 4, false, false, false, Vector2(5, 0))
				else:
					tilemap.set_cell(x, y, 4, false, false, false, Vector2(7, 0))
			x += 1

	for y in range(gen_bottom, gen_bottom + gen_range):
		for x in range(0, 15):
			var tile_id = tilemap.get_cell(x, y)
			if tile_id == 0:
				tilemap.set_cell(x, y, -1)
				_create_instance(Fuel.instance(), x, y)
			elif tile_id == 1:
				tilemap.set_cell(x, y, -1)
				_create_instance(Gem.instance(), x, y)
			elif tile_id == 6:
				tilemap.set_cell(x, y, -1)
				_create_instance(Spike.instance(), x, y)
			elif tile_id == 8:
				tilemap.set_cell(x, y, -1)


	for y in range(gen_bottom, gen_bottom + gen_range):
		border.set_cell(-1, y, \
			4, false, false, false, Vector2(8, 0))
		border.set_cell(15, y, \
			4, false, false, false, Vector2(8, 0))

	gen_bottom = gen_bottom + gen_range

func _can_spawn(rect: Rect2, x: int, y: int) -> bool:
	if (x + rect.size.x - 1) >= 15:
		return false
	for y1 in int(rect.end.y):
		for x1 in int(rect.end.x):
			if tilemap.get_cell(x + x1, y + y1) > 0:
				return false
	return true

func _spawn_premade(inst_tilemap: TileMap, rect: Rect2, x: int, y: int):
	for y1 in int(rect.end.y):
		for x1 in int(rect.end.x):
			var id1 = inst_tilemap.get_cell(x1, y1)
			var auto1 = inst_tilemap.get_cell_autotile_coord(x1, y1)
			tilemap.set_cell(x + x1, y + y1, id1, false, false, false, auto1)

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
