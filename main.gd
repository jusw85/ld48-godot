extends Node2D


onready var tilemap: TileMap = $"Level/TileMap"

var bounds_min: Vector2
var bounds_max: Vector2

func _ready() -> void:
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


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and \
			(OS.get_name() == "Windows" or
			OS.get_name() == "OSX" or
			OS.get_name() == "X11"):
		get_tree().quit()
	
