extends Node2D


onready var tilemap: TileMap = $TileMap

var bounds_min := Vector2(INF, INF)
var bounds_max := Vector2(-INF, -INF)

const Fuel := preload("res://collectibles/fuel.tscn")
const Gem := preload("res://collectibles/gem.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	_calculate_map_bounds()
	_replace_map_tiles_with_objects()


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


func _replace_map_tiles_with_objects():
	var fuels = tilemap.get_used_cells_by_id(0)
	for pos in fuels:
		tilemap.set_cellv(pos, -1)
		var instance = Fuel.instance()
		add_child(instance)
		var local_pos = tilemap.map_to_world(pos)
		var global_pos = tilemap.to_global(local_pos)
		instance.position = local_pos

	var gems = tilemap.get_used_cells_by_id(1)
	for pos in gems:
		tilemap.set_cellv(pos, -1)
		var instance = Gem.instance()
		add_child(instance)
		var local_pos = tilemap.map_to_world(pos)
		var global_pos = tilemap.to_global(local_pos)
		instance.position = local_pos
