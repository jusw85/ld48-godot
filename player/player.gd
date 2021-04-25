extends KinematicBody2D


class TileInfo:
	var grid_pos: Vector2
	var tile_id: int
	var autotile_id: Vector2


enum STATES {IDLE, DEAD, WALKING, FALLING, PUNCH_R, PUNCH_D}
var state = STATES.IDLE

signal fuel_changed
signal gem_changed

export var walk_speed := 600.0
export var gravity := 500.0
export var start_fuel := 30

var fuel: int
var gem := 0
var to_del_downpunch: TileInfo

const End := preload("res://gui/end.tscn")
const RockBreak := preload("res://level/rock_anim.tscn")

const Main := preload("res://main.gd")
onready var game: Main = $"../"
onready var tilemap: TileMap = $"../Level/TileMap"
const DirectionalInput := preload("res://player/directional_input.gd")
onready var dir_input: DirectionalInput = $DirectionalInput
onready var ground_cast: RayCast2D = $GroundCast
onready var r_cast: RayCast2D = $RightCast
onready var l_cast: RayCast2D = $LeftCast
onready var sprite: AnimatedSprite = $AnimatedSprite


func _ready() -> void:
	fuel = start_fuel


func _unhandled_input(event: InputEvent) -> void:
	if state == STATES.DEAD:
		if event.is_action_pressed("restart"):
			get_tree().reload_current_scene()
		else:
			return


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
	if state == STATES.PUNCH_R:
		assert(sprite.animation == "punchright")
		return
	elif state == STATES.PUNCH_D:
		assert(sprite.animation == "punchdown")
		return

	var is_grounded = ground_cast.is_colliding()
	var dir = dir_input.get_input()
	if state == STATES.DEAD:
		dir = Vector2.ZERO

	var velocity = Vector2()
	velocity.x = dir.x * walk_speed
	velocity.y += gravity
	velocity.y = clamp(velocity.y, 0, INF)
	move_and_slide(velocity)

	if is_grounded and r_cast.is_colliding() and dir.x > 0:
		var pos := r_cast.get_collision_point()
		pos.x += 1
		if _try_eat_rock(pos):
			state = STATES.PUNCH_R

	if state == STATES.IDLE and is_grounded and l_cast.is_colliding() and dir.x < 0:
		var pos := l_cast.get_collision_point()
		pos.x -= 1
		if _try_eat_rock(pos):
			state = STATES.PUNCH_R

	if state == STATES.IDLE and is_grounded and dir.y > 0:
		var pos := ground_cast.get_collision_point()
		pos.y += 1

		var tileinfo := _global_pos_to_tileinfo(pos)
		if tileinfo.tile_id == 4:
			change_fuel(-1)
			state = STATES.PUNCH_D
			to_del_downpunch = tileinfo

	if state == STATES.DEAD:
		sprite.play("idle")
	else:
		if state == STATES.PUNCH_R:
			sprite.play("punchright")
		elif state == STATES.PUNCH_D:
			sprite.play("punchdown")
		elif is_grounded and velocity.x != 0.0:
			sprite.play("walking")
		else:
			sprite.play("idle")
	_flip_sprite(dir.x)


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


func _try_eat_rock(pos: Vector2) -> bool:
	var tileinfo := _global_pos_to_tileinfo(pos)
	if tileinfo.tile_id == 4:
		change_fuel(-1)
		var rock_id := int(tileinfo.autotile_id.x)
		if rock_id == 1:
			_spawn_rockbreak(tileinfo, 1)
			tilemap.set_cellv(tileinfo.grid_pos, -1)
		else:
			if rock_id == 7 or \
				rock_id == 5 or \
				rock_id == 3:
				_spawn_rockbreak(tileinfo, rock_id)
			var new_autotile = tileinfo.autotile_id
			new_autotile.x -= 1
			tilemap.set_cell(tileinfo.grid_pos.x, tileinfo.grid_pos.y, \
				tileinfo.tile_id, false, false, false, new_autotile)
		return true
	return false


func _spawn_rockbreak(tileinfo: TileInfo, num: int) -> void:
	var rb = RockBreak.instance()
	tilemap.add_child(rb)
	rb.position = tilemap.map_to_world(tileinfo.grid_pos)
	rb.start("crumble" + str(num))


func _flip_sprite(x_input: int) -> void:
	if x_input > 0:
		sprite.flip_h = false
	elif x_input < 0:
		sprite.flip_h = true


func _on_AnimatedSprite_animation_finished():
	if sprite.animation == "punchright":
		sprite.animation = "idle"
		state = STATES.IDLE
	elif sprite.animation == "punchdown":
		var tileinfo = to_del_downpunch
		var rock_id := int(tileinfo.autotile_id.x)
		if rock_id == 1:
			_spawn_rockbreak(tileinfo, 1)
			tilemap.set_cellv(tileinfo.grid_pos, -1)
		else:
			if rock_id == 7 or \
				rock_id == 5 or \
				rock_id == 3:
				_spawn_rockbreak(tileinfo, rock_id)
			var new_autotile = tileinfo.autotile_id
			new_autotile.x -= 1
			tilemap.set_cell(tileinfo.grid_pos.x, tileinfo.grid_pos.y, \
				tileinfo.tile_id, false, false, false, new_autotile)
		sprite.animation = "idle"
		state = STATES.IDLE

	if fuel <= 0:
		sprite.animation = "idle"
		state = STATES.DEAD
		return
