extends Camera2D

var _map_bounds_left: float
var _map_bounds_right: float

onready var target = $"../Player"
onready var map = $"../Map"


func _ready():
	_map_bounds_left = map.bounds_min.x + 64.0
	_map_bounds_right = map.bounds_max.x - 64.0
	limit_left = int(_map_bounds_left)
	limit_right = int(_map_bounds_right)


func _process(_delta):
	position = target.position
	if position.x < _map_bounds_left + 64.0:
		limit_left = int(position.x - 64.0)
	else:
		limit_left = int(_map_bounds_left)

	if position.x > _map_bounds_right - 64.0:
		limit_right = int(position.x + 64.0)
	else:
		limit_right = int(_map_bounds_right)
