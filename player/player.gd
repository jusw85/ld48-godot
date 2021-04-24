extends KinematicBody2D


signal fuel_changed
signal gem_changed

export var start_fuel := 30
export var start_pos := Vector2(1, -1)
export var fuel_pickup_value := 1

var fuel: int
var gem := 0
var grid_pos: Vector2

#const DirectionalInput := preload("res://player/directional_input.gd")
#onready var directional_input: DirectionalInput = $DirectionalInput

onready var tilemap: TileMap = $"../Level/TileMap"


func _ready() -> void:
	fuel = start_fuel
	grid_pos = start_pos
	_grid_to_pos()


func _unhandled_input(event: InputEvent) -> void:
	var left_just_pressed := event.is_action_pressed("ui_left")
	var right_just_pressed := event.is_action_pressed("ui_right")
	var up_just_pressed := event.is_action_pressed("ui_up")
	var down_just_pressed := event.is_action_pressed("ui_down")
	
	if right_just_pressed:
		_handle_move(1, 0)
	if left_just_pressed:
		_handle_move(-1, 0)
	if down_just_pressed:
		_handle_move(0, 1)
	if up_just_pressed:
		_handle_move(0, -1)


func _handle_move(x: int, y: int):
	_add_fuel(-1)
	_grid_move(x, y)
	var tile := tilemap.get_cellv(grid_pos)
	match tile:
		0:
			_add_fuel(fuel_pickup_value)
		1:
			gem += 1
			emit_signal("gem_changed", gem)
	tilemap.set_cellv(grid_pos, -1)


func _add_fuel(val: int):
	fuel += val
	fuel = clamp(fuel, 0, INF)
	emit_signal("fuel_changed", fuel)
	

func _grid_move(x: int, y: int) -> bool:
	grid_pos.x += x
	grid_pos.y += y
	grid_pos.y = clamp(grid_pos.y, -1, 31)
	grid_pos.x = clamp(grid_pos.x, 0, 19)
	_grid_to_pos()
	return true


func _grid_to_pos():
	position.x = 32 + (grid_pos.x * 64)
	position.y = 32 + ((grid_pos.y + 1) * 64)
	
	
func _physics_process(_delta) -> void:
	pass
#	var dir = directional_input.get_input()
#	move_and_collide(velocity)

