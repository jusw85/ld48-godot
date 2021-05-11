# warning-ignore-all:return_value_discarded
extends KinematicBody2D

# BUG: check collectibles being destroyed on creation below due to visibility notifier?
# visibility notifier for spikes
# fsm
# check store velocity between frames, increasing gravity
# possible: remove references to ..* i.e. map, so scene can standalone
# fix depth calculation
# reorder tilemap ids
# positional audio for punch
# tighten controls
# collectible AOE, --> (fly to player)
# reduce spike aoe
# dust effect on drop
# lerp global camera
# texture (cross) hatch shader
# HUD bars
# HUD depth slider?

signal fuel_changed(fuel)
signal gem_changed(gem)
signal depth_changed(depth)
signal level_changed(level)
signal player_died

enum State { IDLE, PUNCH_R, PUNCH_D, FALLING, WALKING, DEAD }

export var walk_speed := 600.0
export var gravity := 500.0
export var start_fuel := 30
export var xp_to_level := [2, 4, 6]
export var punch_strength := [1, 2, 3, 4]

var gem := 0 setget gem_set
var depth := -1
var xp_level := 0
var to_del_downpunch
var _fsm: NC.StateMachine

onready var fuel := start_fuel setget fuel_set
onready var player_frames = [
	preload("res://player/person1_ss.png"),
	preload("res://player/person2_ss.png"),
	preload("res://player/person3_ss.png"),
	preload("res://player/person4_ss.png"),
]
onready var map = $"../Map"
onready var directional_input: NC.DirectionalInput = $DirectionalInput
onready var ground_cast: RayCast2D = $GroundCast
onready var d_cast: RayCast2D = $DownCast
onready var r_cast: RayCast2D = $RightCast
onready var l_cast: RayCast2D = $LeftCast
onready var sprite: Sprite = $Sprite
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var mask: Sprite = $Mask
onready var punch_sfx: AudioStreamPlayer = $PunchSfx
onready var crumble_sfx: AudioStreamPlayer = $CrumbleSfx
onready var invuln_timer: Timer = $InvulnTimer
onready var sprite_flasher: NC.SpriteFlasher = $Sprite/SpriteFlasher

func _ready() -> void:
	_fsm = NC.StateMachine.new()
	_fsm.init_funcs(self, State)
	_fsm.change_state(State.IDLE)


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
#	print(OS.get_ticks_msec())

	# collect input
	# simulate and update internal variables
	# transition state
	_fsm.process_state()


func _enter_idle():
	animation_player.play("idle")


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
		_fsm.change_state(State.FALLING)
	# check dead
	elif fuel <= 0:
		_fsm.change_state(State.DEAD)
		emit_signal("player_died")

	# check attack
	elif r_cast.is_colliding() and dir.x > 0:
		r_cast.get_collider().get_parent().break_rock(punch_strength[xp_level], xp_level)
		self.fuel -= 1
		punch_sfx.play()
		_fsm.change_state(State.PUNCH_R)
	elif l_cast.is_colliding() and dir.x < 0:
		l_cast.get_collider().get_parent().break_rock(punch_strength[xp_level], xp_level)
		self.fuel -= 1
		punch_sfx.play()
		_fsm.change_state(State.PUNCH_R)
	elif d_cast.is_colliding() and dir.y > 0:
		to_del_downpunch = d_cast.get_collider().get_parent()
		self.fuel -= 1
		punch_sfx.play()
		_fsm.change_state(State.PUNCH_D)

	elif dir.x != 0.0:
		_fsm.change_state(State.WALKING)


func _enter_punch_r():
	animation_player.play("punch_r")


func _process_punch_r():
	pass
#	assert(animation_player.current_animation == "punch_r")


func _enter_punch_d():
	animation_player.play("punch_d")


func _process_punch_d():
#	print("_process_punch_d")
	pass
#	assert(animation_player.current_animation == "punch_d")


func _enter_falling():
	animation_player.play("idle")


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
		_fsm.change_state(State.DEAD)
		emit_signal("player_died")

	# check attack
	elif r_cast.is_colliding() and dir.x > 0:
		r_cast.get_collider().get_parent().break_rock(punch_strength[xp_level], xp_level)
		self.fuel -= 1
		punch_sfx.play()
		_fsm.change_state(State.PUNCH_R)
	elif l_cast.is_colliding() and dir.x < 0:
		l_cast.get_collider().get_parent().break_rock(punch_strength[xp_level], xp_level)
		self.fuel -= 1
		punch_sfx.play()
		_fsm.change_state(State.PUNCH_R)
	elif d_cast.is_colliding() and dir.y > 0:
		to_del_downpunch = d_cast.get_collider().get_parent()
		self.fuel -= 1
		punch_sfx.play()
		_fsm.change_state(State.PUNCH_D)

	elif dir.x != 0.0:
		_fsm.change_state(State.WALKING)
	else:
		_fsm.change_state(State.IDLE)


func _enter_walking():
	animation_player.play("walking")


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
		_fsm.change_state(State.FALLING)
	# check dead
	elif fuel <= 0:
		_fsm.change_state(State.DEAD)
		emit_signal("player_died")

	# check attack
	elif r_cast.is_colliding() and dir.x > 0:
		r_cast.get_collider().get_parent().break_rock(punch_strength[xp_level], xp_level)
		self.fuel -= 1
		punch_sfx.play()
		_fsm.change_state(State.PUNCH_R)
	elif l_cast.is_colliding() and dir.x < 0:
		l_cast.get_collider().get_parent().break_rock(punch_strength[xp_level], xp_level)
		self.fuel -= 1
		punch_sfx.play()
		_fsm.change_state(State.PUNCH_R)
	elif d_cast.is_colliding() and dir.y > 0:
		to_del_downpunch = d_cast.get_collider().get_parent()
		self.fuel -= 1
		punch_sfx.play()
		_fsm.change_state(State.PUNCH_D)

	elif dir.x == 0.0:
		_fsm.change_state(State.IDLE)


func _enter_dead():
	animation_player.play("idle")


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


func damage(dmg: int):
	if _fsm.state == State.DEAD:
		return
	if invuln_timer.time_left <= 0:
		self.fuel -= dmg
		invuln_timer.start()
		sprite_flasher.flash(0.25)


func gem_set(val: int) -> void:
	gem = int(max(val, 0))
	emit_signal("gem_changed", gem)
	if xp_level < xp_to_level.size() and gem >= xp_to_level[xp_level]:
		xp_level += 1
		sprite.texture = player_frames[xp_level]
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


func _on_InvulnTimer_timeout():
	sprite_flasher.stop()


func _before_punch_d_finish():
#	print("_before_punch_d_finish()")
#	print(OS.get_ticks_msec())

#	map.break_rock(to_del_downpunch, punch_strength[xp_level], xp_level)
	pass


func _on_AnimationPlayer_animation_finished(_anim_name):
	if not (_fsm.state == State.PUNCH_D or _fsm.state == State.PUNCH_R):
		return
#	print("_on_AnimationPlayer_animation_finished()")
#	print(OS.get_ticks_msec())

	if _fsm.state == State.PUNCH_D:
		to_del_downpunch.break_rock(punch_strength[xp_level], xp_level)
		ground_cast.force_raycast_update()
		d_cast.force_raycast_update()
#		map.break_rock(to_del_downpunch, punch_strength[xp_level], xp_level)
#		ground_cast.force_raycast_update()

#   move this to process? for simulation

	var dir = directional_input.get_input_direction()
	var is_grounded = ground_cast.is_colliding()

#	1 frame tilemap off for is_grounded
#	https://github.com/godotengine/godot/issues/48397
#   becomes falling here for change tile

	# check transitions
	if not is_grounded:
		_fsm.change_state(State.FALLING)
	# check dead
	elif fuel <= 0:
		_fsm.change_state(State.DEAD)
		emit_signal("player_died")

	# check attack
	elif r_cast.is_colliding() and dir.x > 0:
		r_cast.get_collider().get_parent().break_rock(punch_strength[xp_level], xp_level)
		self.fuel -= 1
		punch_sfx.play()
		_fsm.change_state(State.PUNCH_R)
	elif l_cast.is_colliding() and dir.x < 0:
		l_cast.get_collider().get_parent().break_rock(punch_strength[xp_level], xp_level)
		self.fuel -= 1
		punch_sfx.play()
		_fsm.change_state(State.PUNCH_R)
	elif d_cast.is_colliding() and dir.y > 0:
		to_del_downpunch = d_cast.get_collider().get_parent()
		self.fuel -= 1
		punch_sfx.play()
		_fsm.change_state(State.PUNCH_D)

	elif dir.x != 0.0:
		_fsm.change_state(State.WALKING)
	else:
		_fsm.change_state(State.IDLE)
