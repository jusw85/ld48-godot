extends KinematicBody2D


# 	TODO: check store velocity between frames, increasing gravity
# player: state machine
# fix depth
# reorder tilemap ids
# positional audio for punch
# tighten controls
# collectible AOE fly to player
# dust effect on drop
# lerp global camera

signal fuel_changed(fuel)
signal gem_changed(gem)
signal depth_changed(depth)
signal level_changed(level)
signal player_died()

enum State { IDLE, PUNCH_R, PUNCH_D, DEAD, WALKING, FALLING }
var state = State.IDLE

export var walk_speed := 600.0
export var gravity := 500.0
export var start_fuel := 30
export var xp_to_level := [2, 4, 6]
export var punch_strength := [1, 2, 3, 4]

var gem := 0 setget gem_set
var depth := -1
var xp_level := 0
var to_del_downpunch: Vector2

onready var fuel := start_fuel setget fuel_set
onready var player_frames = [
	preload("res://player/player0.tres"),
	preload("res://player/player1.tres"),
	preload("res://player/player2.tres"),
	preload("res://player/player3.tres")
]
onready var map = $"../Map"
onready var directional_input: NC.DirectionalInput = $DirectionalInput
onready var ground_cast: RayCast2D = $GroundCast
onready var r_cast: RayCast2D = $RightCast
onready var l_cast: RayCast2D = $LeftCast
onready var sprite: AnimatedSprite = $AnimatedSprite
onready var mask: Sprite = $Mask
onready var punch_sfx: AudioStreamPlayer = $PunchSfx
onready var crumble_sfx: AudioStreamPlayer = $CrumbleSfx
onready var invuln_timer: Timer = $InvulnTimer
onready var flash_tween: Tween = $FlashTween


func _ready() -> void:

	sprite.playing = true
	_enter_idle()
	state = State.IDLE

#class FrameInfo:
#	var dir: Vector2
#	var is_grounded: bool
#	var grid_pos: Vector2
#	var velocity: Vector2
#
#
#func _get_frame_info() -> FrameInfo:
#	var frame_info = FrameInfo.new()
#	frame_info.dir = directional_input.get_input_direction()
#	frame_info.is_grounded = ground_cast.is_colliding()
#	frame_info.grid_pos = map.get_grid_pos(global_position)
#
#	var velocity = Vector2.ZERO
#	velocity.x = frame_info.dir.x * walk_speed
#	velocity.y += gravity
#	velocity.y = clamp(velocity.y, 0, INF)
#	frame_info.velocity = velocity
#	return frame_info


func _physics_process(_delta) -> void:
	# collect input
	# simulate and update internal variables
	# transition state

	# preload funcrefs

#	print(State.keys()[state])
	match state:
		State.IDLE:
			_process_idle()
		State.WALKING:
			_process_walking()
		State.DEAD:
			_process_dead()
		State.PUNCH_R:
			_process_punch_r()
		State.PUNCH_D:
			_process_punch_d()
		State.FALLING:
			_process_falling()


func _enter_idle():
	sprite.animation = "idle"
	sprite.frame = 0


func _process_idle():
#	var frame_info = _get_frame_info()
	var dir = directional_input.get_input_direction()
	var is_grounded = ground_cast.is_colliding()
	var grid_pos = map.get_grid_pos(global_position)

	var velocity = Vector2.ZERO
	velocity.x = dir.x * walk_speed
	velocity.y += gravity
	velocity.y = clamp(velocity.y, 0, INF)
	move_and_slide(velocity)

	# update new depth
	if not Globals.is_hell:
		var new_depth = grid_pos.y
		if new_depth != depth:
			var mask_size = clamp(1.0 - (new_depth / 160.0), 0.0, 1.0)
			mask.material.set_shader_param("size", mask_size)
			depth = new_depth
			map.check_create_map(depth)
			emit_signal("depth_changed", depth)

	_flip_sprite(dir.x)
	# check transitions
	if not is_grounded:
		_enter_falling()
		state = State.FALLING
	# check dead
	elif fuel <= 0:
		_enter_dead()
		state = State.DEAD
		emit_signal("player_died")

	# check attack
	elif r_cast.is_colliding() and dir.x > 0:
		var check_grid_pos = Vector2(grid_pos.x + 1, grid_pos.y)
		if map.is_rock(check_grid_pos):
			map.break_rock(check_grid_pos, punch_strength[xp_level])
			self.fuel -= 1
			punch_sfx.play()
			_enter_punch_r()
			state = State.PUNCH_R

	elif l_cast.is_colliding() and dir.x < 0:
		var check_grid_pos = Vector2(grid_pos.x - 1, grid_pos.y)
		if map.is_rock(check_grid_pos):
			map.break_rock(check_grid_pos, punch_strength[xp_level])
			self.fuel -= 1
			punch_sfx.play()
			_enter_punch_r()
			state = State.PUNCH_R

	elif dir.y > 0:
		var check_grid_pos = Vector2(grid_pos.x, grid_pos.y + 1)
		if map.is_rock(check_grid_pos):
			self.fuel -= 1
			punch_sfx.play()
			_enter_punch_d()
			state = State.PUNCH_D
			to_del_downpunch = check_grid_pos

	elif dir.x != 0.0:
		_enter_walking()
		state = State.WALKING


func _enter_punch_r():
	sprite.animation = "punchright"
	sprite.frame = 0

func _process_punch_r():
	assert(sprite.animation == "punchright")

func _enter_punch_d():
	sprite.animation = "punchdown"
	sprite.frame = 0

func _process_punch_d():
	assert(sprite.animation == "punchdown")

func _enter_falling():
	sprite.animation = "idle"
	sprite.frame = 0

func _process_falling():
	var dir = directional_input.get_input_direction()
	var is_grounded = ground_cast.is_colliding()
	var grid_pos = map.get_grid_pos(global_position)

	var velocity = Vector2.ZERO
	velocity.x = dir.x * walk_speed
	velocity.y += gravity
	velocity.y = clamp(velocity.y, 0, INF)
	move_and_slide(velocity)

	# update new depth
	if not Globals.is_hell:
		var new_depth = grid_pos.y
		if new_depth != depth:
			var mask_size = clamp(1.0 - (new_depth / 160.0), 0.0, 1.0)
			mask.material.set_shader_param("size", mask_size)
			depth = new_depth
			map.check_create_map(depth)
			emit_signal("depth_changed", depth)

	_flip_sprite(dir.x)
	# check transitions
	if not is_grounded:
		return
	# check dead
	elif fuel <= 0:
		_enter_dead()
		state = State.DEAD
		emit_signal("player_died")

	# check attack
	elif r_cast.is_colliding() and dir.x > 0:
		var check_grid_pos = Vector2(grid_pos.x + 1, grid_pos.y)
		if map.is_rock(check_grid_pos):
			map.break_rock(check_grid_pos, punch_strength[xp_level])
			self.fuel -= 1
			punch_sfx.play()
			_enter_punch_r()
			state = State.PUNCH_R

	elif l_cast.is_colliding() and dir.x < 0:
		var check_grid_pos = Vector2(grid_pos.x - 1, grid_pos.y)
		if map.is_rock(check_grid_pos):
			map.break_rock(check_grid_pos, punch_strength[xp_level])
			self.fuel -= 1
			punch_sfx.play()
			_enter_punch_r()
			state = State.PUNCH_R

	elif dir.y > 0:
		var check_grid_pos = Vector2(grid_pos.x, grid_pos.y + 1)
		if map.is_rock(check_grid_pos):
			self.fuel -= 1
			punch_sfx.play()
			_enter_punch_d()
			state = State.PUNCH_D
			to_del_downpunch = check_grid_pos

	elif dir.x != 0.0:
		_enter_walking()
		state = State.WALKING
	else:
		_enter_idle()
		state = State.IDLE

func _enter_walking():
	sprite.animation = "walking"
	sprite.frame = 0

func _process_walking():
#	var frame_info = _get_frame_info()
	var dir = directional_input.get_input_direction()
	var is_grounded = ground_cast.is_colliding()
	var grid_pos = map.get_grid_pos(global_position)

	var velocity = Vector2.ZERO
	velocity.x = dir.x * walk_speed
	velocity.y += gravity
	velocity.y = clamp(velocity.y, 0, INF)
	move_and_slide(velocity)

	# update new depth
	if not Globals.is_hell:
		var new_depth = grid_pos.y
		if new_depth != depth:
			var mask_size = clamp(1.0 - (new_depth / 160.0), 0.0, 1.0)
			mask.material.set_shader_param("size", mask_size)
			depth = new_depth
			map.check_create_map(depth)
			emit_signal("depth_changed", depth)

	_flip_sprite(dir.x)
	# check transitions
	if not is_grounded:
		_enter_falling()
		state = State.FALLING
	# check dead
	elif fuel <= 0:
		_enter_dead()
		state = State.DEAD
		emit_signal("player_died")

	# check attack
	elif r_cast.is_colliding() and dir.x > 0:
		var check_grid_pos = Vector2(grid_pos.x + 1, grid_pos.y)
		if map.is_rock(check_grid_pos):
			map.break_rock(check_grid_pos, punch_strength[xp_level])
			self.fuel -= 1
			punch_sfx.play()
			_enter_punch_r()
			state = State.PUNCH_R

	elif l_cast.is_colliding() and dir.x < 0:
		var check_grid_pos = Vector2(grid_pos.x - 1, grid_pos.y)
		if map.is_rock(check_grid_pos):
			map.break_rock(check_grid_pos, punch_strength[xp_level])
			self.fuel -= 1
			punch_sfx.play()
			_enter_punch_r()
			state = State.PUNCH_R

	elif dir.y > 0:
		var check_grid_pos = Vector2(grid_pos.x, grid_pos.y + 1)
		if map.is_rock(check_grid_pos):
			self.fuel -= 1
			punch_sfx.play()
			_enter_punch_d()
			state = State.PUNCH_D
			to_del_downpunch = check_grid_pos

	elif dir.x == 0.0:
		_enter_idle()
		state = State.IDLE

func _enter_dead():
	sprite.animation = "idle"
	sprite.frame = 0

func _process_dead():
	var grid_pos = map.get_grid_pos(global_position)

	var velocity = Vector2.ZERO
	velocity.y += gravity
	velocity.y = clamp(velocity.y, 0, INF)
	move_and_slide(velocity)

	# check new depth
	if not Globals.is_hell:
		var new_depth = grid_pos.y
		if new_depth != depth:
			var mask_size = clamp(1.0 - (new_depth / 160.0), 0.0, 1.0)
			mask.material.set_shader_param("size", mask_size)
			depth = new_depth
			map.check_create_map(depth)
			emit_signal("depth_changed", depth)


func _flip_sprite(x_input: int) -> void:
	if x_input > 0:
		sprite.flip_h = false
	elif x_input < 0:
		sprite.flip_h = true


func _on_AnimatedSprite_animation_finished():
	if not (state == State.PUNCH_D or state == State.PUNCH_R):
		return

	if state == State.PUNCH_D:
		map.break_rock(to_del_downpunch, punch_strength[xp_level])

	ground_cast.force_raycast_update()
	var dir = directional_input.get_input_direction()
	var is_grounded = ground_cast.is_colliding()
	var grid_pos = map.get_grid_pos(global_position)

#	1 frame tilemap off for is_grounded
#	https://github.com/godotengine/godot/issues/48397

	# check transitions
	if not is_grounded:
		_enter_falling()
		state = State.FALLING
	# check dead
	elif fuel <= 0:
		_enter_dead()
		state = State.DEAD
		emit_signal("player_died")

	# check attack
	elif r_cast.is_colliding() and dir.x > 0:
		var check_grid_pos = Vector2(grid_pos.x + 1, grid_pos.y)
		if map.is_rock(check_grid_pos):
			map.break_rock(check_grid_pos, punch_strength[xp_level])
			self.fuel -= 1
			punch_sfx.play()
			_enter_punch_r()
			state = State.PUNCH_R

	elif l_cast.is_colliding() and dir.x < 0:
		var check_grid_pos = Vector2(grid_pos.x - 1, grid_pos.y)
		if map.is_rock(check_grid_pos):
			map.break_rock(check_grid_pos, punch_strength[xp_level])
			self.fuel -= 1
			punch_sfx.play()
			_enter_punch_r()
			state = State.PUNCH_R

	elif dir.y > 0:
		var check_grid_pos = Vector2(grid_pos.x, grid_pos.y + 1)
		if map.is_rock(check_grid_pos):
			self.fuel -= 1
			punch_sfx.play()
			_enter_punch_d()
			state = State.PUNCH_D
			to_del_downpunch = check_grid_pos

	elif dir.x != 0.0:
		_enter_walking()
		state = State.WALKING
	else:
		_enter_idle()
		state = State.IDLE


func damage(dmg: int):
	if state == State.DEAD:
		return
	if invuln_timer.time_left <= 0:
		self.fuel -= dmg
		invuln_timer.start()
		while invuln_timer.time_left > 0:
			flash_tween.interpolate_property(
				sprite.material, "shader_param/flash_amount", 0.0, 1.0, 0.25
			)
			flash_tween.start()
			yield(flash_tween, "tween_all_completed")
			flash_tween.interpolate_property(
				sprite.material, "shader_param/flash_amount", 1.0, 0.0, 0.25
			)
			flash_tween.start()
			yield(flash_tween, "tween_all_completed")


func gem_set(val: int) -> void:
	gem = int(max(val, 0))
	emit_signal("gem_changed", gem)
	if xp_level < xp_to_level.size() and gem >= xp_to_level[xp_level]:
		xp_level += 1
		sprite.frames = player_frames[xp_level]
		emit_signal("level_changed", xp_level)


func fuel_set(val: int) -> void:
	fuel = int(max(val, 0))
	emit_signal("fuel_changed", fuel)


func do_hell():
	Globals.is_hell = true
	emit_signal("depth_changed", 666)
	$Mask2.visible = true
	var mask_tween = $MaskTween
	mask_tween.interpolate_property(
		mask.material, "shader_param/size", mask.material.get_shader_param("size"), 1.0, 0.25
	)
	mask_tween.start()

	var camera_tween = $CameraTween
	camera_tween.interpolate_property(Globals.camera, "offset:y", null, -144.0, 0.15)
	camera_tween.start()
