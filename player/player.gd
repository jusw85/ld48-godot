extends KinematicBody2D


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
	var velocity = Vector2()
	var dir = dir_input.get_input()
	velocity.x = dir.x * walk_speed
	velocity.y += gravity
	velocity.y = clamp(velocity.y, 0, INF)
	move_and_slide(velocity)
