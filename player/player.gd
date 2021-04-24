extends KinematicBody2D


class TileInfo:
	var grid_pos: Vector2
	var tile_id: int
	var autotile_id: Vector2


enum STATES {ALIVE, DEAD}
var state = STATES.ALIVE

signal fuel_changed
signal gem_changed

export var walk_speed := 600.0
export var gravity := 500.0
export var start_fuel := 30
export var soil_fuel_needed := 1
export var rock_fuel_needed := 2

var fuel: int
var gem := 0

const End := preload("res://gui/end.tscn")

const Main := preload("res://main.gd")
onready var game: Main = $"../"
onready var tilemap: TileMap = $"../Level/TileMap"
const DirectionalInput := preload("res://player/directional_input.gd")
onready var dir_input: DirectionalInput = $DirectionalInput
onready var ground_cast: RayCast2D = $GroundCast
onready var r_cast: RayCast2D = $RightCast
onready var l_cast: RayCast2D = $LeftCast


func _ready() -> void:
	fuel = start_fuel


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
		pos.y += 1
		_try_eat_rock(pos)


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
	

func _physics_process(_delta) -> void:
	if state == STATES.DEAD:
		return
	var is_grounded = ground_cast.is_colliding()
	var velocity = Vector2()
	var dir = dir_input.get_input()
	velocity.x = dir.x * walk_speed
	velocity.y += gravity
	velocity.y = clamp(velocity.y, 0, INF)
	move_and_slide(velocity)

	if is_grounded and r_cast.is_colliding() and dir.x > 0:
		var pos := r_cast.get_collision_point()
		pos.x += 1
		_try_eat_rock(pos)

	if is_grounded and l_cast.is_colliding() and dir.x < 0:
		var pos := l_cast.get_collision_point()
		pos.x -= 1
		_try_eat_rock(pos)


func _global_pos_to_tileinfo(pos: Vector2) -> TileInfo:
	var tile_info = TileInfo.new()
	
	pos = tilemap.to_local(pos)
	var grid_pos := tilemap.world_to_map(pos)
	var tile_id := tilemap.get_cellv(grid_pos)
	var autotile_id := tilemap.get_cell_autotile_coord(grid_pos.x, grid_pos.y)
	
	tile_info.grid_pos = grid_pos
	tile_info.tile_id = tile_id
	tile_info.autotile_id = autotile_id
	return tile_info


func _try_eat_rock(pos: Vector2) -> void:
	var tileinfo := _global_pos_to_tileinfo(pos)
	if tileinfo.tile_id == 4:
		tilemap.set_cellv(tileinfo.grid_pos, -1)
		var rock_id := int(tileinfo.autotile_id.x)
		match rock_id:
			1:
				change_fuel(-soil_fuel_needed)
			7:
				change_fuel(-rock_fuel_needed)
			_:
				change_fuel(-soil_fuel_needed)
