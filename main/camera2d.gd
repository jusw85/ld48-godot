extends Camera2D

var cam_left_x: float
var cam_right_x: float

onready var player = $"../Player"
onready var map = $"../Map"


func _ready():
	cam_left_x = map.bounds_min.x
	cam_right_x = map.bounds_max.x + 64
	limit_left = cam_left_x
	limit_right = cam_right_x


func _process(_delta):
	position = player.position
	if position.x < cam_left_x + 64:
		limit_left = position.x - 64
	else:
		limit_left = cam_left_x

	if position.x > cam_right_x - 64:
		limit_right = position.x + 64
	else:
		limit_right = cam_right_x
