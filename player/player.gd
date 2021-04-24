extends KinematicBody2D


enum STATES {ALIVE, DEAD}
var state = STATES.ALIVE

signal fuel_changed
signal gem_changed

export var walk_speed := 600.0
export var gravity := 500.0
export var start_fuel := 30
export var start_pos := Vector2(1, -1)
export var gem_pickup_value := 1
export var soil_fuel_needed := 1
export var rock_fuel_needed := 2

var fuel: int
var gem := 0
#var grid_pos: Vector2

const Main := preload("res://main.gd")
const End := preload("res://gui/end.tscn")
const DirectionalInput := preload("res://player/directional_input.gd")
onready var game: Main = $"../"
onready var tilemap: TileMap = $"../Level/TileMap"
onready var dir_input: DirectionalInput = $DirectionalInput
onready var ground_cast: RayCast2D = $GroundCast


func _ready() -> void:
	fuel = start_fuel
#	grid_pos = start_pos
#	_grid_to_pos()


func _unhandled_input(event: InputEvent) -> void:
	if state == STATES.DEAD:
		if event.is_action_pressed("restart"):
			get_tree().reload_current_scene()
		else:
			return

#	var left_just_pressed := event.is_action_pressed("ui_left")
#	var right_just_pressed := event.is_action_pressed("ui_right")
#	var up_just_pressed := event.is_action_pressed("ui_up")

	var down_just_pressed := event.is_action_pressed("ui_down")
	if down_just_pressed and ground_cast.is_colliding():
		var pos := ground_cast.get_collision_point()
		pos = tilemap.to_local(pos)
		var grid_pos := tilemap.world_to_map(pos)
		var tile_id := tilemap.get_cellv(grid_pos)
		if tile_id == 4:
			var auto_id := tilemap.get_cell_autotile_coord(grid_pos.x, grid_pos.y)
			var rock_id := int(auto_id.x)
			tilemap.set_cellv(grid_pos, -1)
			match rock_id:
				1:
					change_fuel(-soil_fuel_needed)
				7:
					change_fuel(-rock_fuel_needed)
				_:
					change_fuel(-soil_fuel_needed)

#	if right_just_pressed:
#		_handle_move(1, 0)
#	if left_just_pressed:
#		_handle_move(-1, 0)
#	if down_just_pressed:
#		_handle_move(0, 1)
#	if up_just_pressed:
#		_handle_move(0, -1)


#func _handle_move(x: int, y: int):
#	var new_pos = grid_pos + Vector2(x, y)
#
##	check OOB
#	if new_pos.x < game.bounds_min.x or \
#		new_pos.x > game.bounds_max.x or \
#		new_pos.y < game.bounds_min.y - 1 or \
#		new_pos.y > game.bounds_max.y:
#		return
#
#	var tile := tilemap.get_cellv(new_pos)
#	match tile:
#		0: # fuel
#			_change_fuel(fuel_pickup_value)
#		1: # gem
#			gem += gem_pickup_value
#			emit_signal("gem_changed", gem)
#		4: # soils
#			var subtype = tilemap.get_cell_autotile_coord(new_pos.x, new_pos.y)
#			if subtype.x == 1:
#				_change_fuel(-soil_fuel_needed)
#			elif subtype.x == 7:
#				_change_fuel(-rock_fuel_needed)
#			else:
#				print("unrecognized soil: " + str(subtype))
#
#	grid_pos = new_pos
#	_grid_to_pos()
#
#	tilemap.set_cellv(grid_pos, -1)


func change_gem(val: int):
	gem += val
	emit_signal("gem_changed", gem)
		
func change_fuel(val: int):
	fuel += val
	fuel = clamp(fuel, 0, INF)
	emit_signal("fuel_changed", fuel)
	if fuel <= 0:
		state = STATES.DEAD
		$"../GUI".add_child(End.instance())
	

#func _grid_to_pos():
#	position.x = 32 + (grid_pos.x * 64)
#	position.y = 32 + ((grid_pos.y + 1) * 64)
	

func _physics_process(_delta) -> void:
	var velocity = Vector2()
	var dir = dir_input.get_input()
	velocity.x = dir.x * walk_speed
	velocity.y += gravity
	velocity.y = clamp(velocity.y, 0, INF)
	move_and_slide(velocity)
