extends KinematicBody2D


signal fuel_changed

export var max_fuel := 30
var fuel: int
var grid_pos := Vector2(1, -1)

#const DirectionalInput := preload("res://player/directional_input.gd")
#onready var directional_input: DirectionalInput = $DirectionalInput

onready var tilemap: TileMap = $"../Level/TileMap"


func _ready() -> void:
	fuel = max_fuel


func _unhandled_input(event: InputEvent) -> void:
	var left_just_pressed := event.is_action_pressed("ui_left")
	var right_just_pressed := event.is_action_pressed("ui_right")
	var up_just_pressed := event.is_action_pressed("ui_up")
	var down_just_pressed := event.is_action_pressed("ui_down")
	if right_just_pressed:
		_use_fuel(1)
		grid_pos.x += 1
		position.x += 64
		tilemap.set_cellv(grid_pos, -1)
	if left_just_pressed:
		_use_fuel(1)
		grid_pos.x -= 1
		position.x -= 64
		tilemap.set_cellv(grid_pos, -1)
	if down_just_pressed:
		_use_fuel(1)
		grid_pos.y += 1
		position.y += 64
		tilemap.set_cellv(grid_pos, -1)
	if up_just_pressed:
		_use_fuel(1)
		grid_pos.y -= 1
		position.y -= 64
		tilemap.set_cellv(grid_pos, -1)


func _use_fuel(val: int):
	fuel -= val
	fuel = clamp(fuel, 0, INF)
	emit_signal("fuel_changed", fuel)
	

func _physics_process(_delta) -> void:
	pass
#	var dir = directional_input.get_input()
#	move_and_collide(velocity)

