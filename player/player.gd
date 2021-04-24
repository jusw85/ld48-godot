extends KinematicBody2D


signal fuel_changed

export var max_fuel := 30
export var start_pos := Vector2(1, -1)
var fuel: int
var grid_pos: Vector2

#const DirectionalInput := preload("res://player/directional_input.gd")
#onready var directional_input: DirectionalInput = $DirectionalInput

onready var tilemap: TileMap = $"../Level/TileMap"


func _ready() -> void:
	fuel = max_fuel
	grid_pos = start_pos
	_grid_to_pos()


func _unhandled_input(event: InputEvent) -> void:
	var left_just_pressed := event.is_action_pressed("ui_left")
	var right_just_pressed := event.is_action_pressed("ui_right")
	var up_just_pressed := event.is_action_pressed("ui_up")
	var down_just_pressed := event.is_action_pressed("ui_down")
	if right_just_pressed:
		_use_fuel(1)
		_grid_move(1, 0)
#		position.x += 64
		tilemap.set_cellv(grid_pos, -1)
	if left_just_pressed:
		_use_fuel(1)
		_grid_move(-1, 0)
#		position.x -= 64
		tilemap.set_cellv(grid_pos, -1)
	if down_just_pressed:
		_use_fuel(1)
		_grid_move(0, 1)
#		position.y += 64
		tilemap.set_cellv(grid_pos, -1)
	if up_just_pressed:
		_use_fuel(1)
		_grid_move(0, -1)
#		position.y -= 64
		tilemap.set_cellv(grid_pos, -1)


func _use_fuel(val: int):
	fuel -= val
	fuel = clamp(fuel, 0, INF)
	emit_signal("fuel_changed", fuel)
	

func _grid_move(x: int, y: int):
	grid_pos.x += x
	grid_pos.y += y
	grid_pos.y = clamp(grid_pos.y, -1, 31)
	grid_pos.x = clamp(grid_pos.x, 0, 19)
	_grid_to_pos()


func _grid_to_pos():
	position.x = 32 + (grid_pos.x * 64)
	position.y = 32 + ((grid_pos.y + 1) * 64)
	
	
func _physics_process(_delta) -> void:
	pass
#	var dir = directional_input.get_input()
#	move_and_collide(velocity)

