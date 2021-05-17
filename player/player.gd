extends KinematicBody2D

# visibility notifier for spikes, blocks for cleanup
# dust effect on drop
# HUD bars
# HUD depth slider?
# low prio: texture (cross) hatch shader
# low prio: reorder tilemap ids (fixed in 4.0)

signal fuel_changed(fuel)  # gui
signal gem_changed(gem)  # gui
signal level_changed(level)  # bgm
signal depth_changed  # main
signal player_died  # main

enum State { IDLE, PUNCH_R, PUNCH_D, FALLING, WALKING, DEAD }

export var walk_speed := 300.0
export var gravity := 2750.0
export var start_fuel := 100
export var xp_to_level := [7, 15, 25]
export var punch_strength := [1, 2, 3, 5]

var gem := 0 setget set_gem
var mask_size setget set_mask_size, get_mask_size

var _velocity := Vector2.ZERO
var _xp_level := 0
var _fsm: NC.StateMachine
var _punch_d_rock
var _punch_d_last_anim := "punch_d2"

onready var fuel := start_fuel setget set_fuel
onready var player_frames = [
	preload("res://player/assets/person1_ss.png"),
	preload("res://player/assets/person2_ss.png"),
	preload("res://player/assets/person3_ss.png"),
	preload("res://player/assets/person4_ss.png"),
]

onready var directional_input: NC.DirectionalInput = $DirectionalInput
onready var ground_cast1: RayCast2D = $GroundCast1
onready var ground_cast2: RayCast2D = $GroundCast2
onready var d_cast: RayCast2D = $DownCast
onready var r_cast: RayCast2D = $RightCast
onready var l_cast: RayCast2D = $LeftCast
onready var sprite: Sprite = $Sprite
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var mask: Sprite = $Mask
onready var punch_sfx: AudioStreamPlayer = $PunchSfx
onready var invuln_timer: Timer = $InvulnTimer
onready var sprite_flasher: NC.SpriteFlasher = $Sprite/SpriteFlasher


func _ready() -> void:
	self.mask_size = 1.0
	sprite.material.set_shader_param("flash_amount", 0.0)

	_fsm = NC.StateMachine.new()
	_fsm.init_funcs(self, State)
	_fsm.change_state(State.IDLE)


func _physics_process(_delta) -> void:
	# collect input
	# simulate and update internal variables
	# transition state
	_fsm.process_state()


func damage(dmg: int):
	if _fsm.state == State.DEAD:
		return
	if invuln_timer.time_left <= 0:
		self.fuel -= dmg
		invuln_timer.start()
		sprite_flasher.flash(0.25)


func set_gem(val: int) -> void:
	assert(val > gem)
	gem = int(max(val, 0))
	emit_signal("gem_changed", gem)
	if _xp_level < xp_to_level.size() and gem >= xp_to_level[_xp_level]:
		_xp_level += 1
		sprite.texture = player_frames[_xp_level]
		emit_signal("level_changed", _xp_level)


func set_fuel(val: int) -> void:
	fuel = int(max(val, 0))
	emit_signal("fuel_changed", fuel)


func get_mask_size() -> float:
	return mask.material.get_shader_param("size")


func set_mask_size(p_mask_size):
	mask_size = clamp(p_mask_size, 0.0, 1.0)
	mask.material.set_shader_param("size", mask_size)


func _enter_idle():
	animation_player.play("idle")


func _process_idle():
	var dir = directional_input.get_input_direction()
	_move(dir)
	_flip_sprite(dir.x)
	var is_grounded = is_on_floor()

	if not is_grounded:
		_fsm.change_state(State.FALLING)
	elif fuel <= 0:
		_fsm.change_state(State.DEAD)
	elif r_cast.is_colliding() and dir.x > 0:
		_fsm.change_state(State.PUNCH_R, [r_cast.get_collider().get_parent()])
	elif l_cast.is_colliding() and dir.x < 0:
		_fsm.change_state(State.PUNCH_R, [l_cast.get_collider().get_parent()])
	elif d_cast.is_colliding() and dir.y > 0:
		_fsm.change_state(State.PUNCH_D, [d_cast.get_collider().get_parent()])
	elif dir.x != 0.0:
		_fsm.change_state(State.WALKING)


func _enter_punch_r(rock):
	animation_player.play("punch_r")
	rock.break_rock(punch_strength[_xp_level], _xp_level)
	self.fuel -= 1
	punch_sfx.play()


func _process_punch_r():
	if animation_player.is_playing():
		return
	var dir = directional_input.get_input_direction()
	_move(dir)
	_flip_sprite(dir.x)
	var is_grounded = is_on_floor()

	if not is_grounded:
		_fsm.change_state(State.FALLING)
	elif fuel <= 0:
		_fsm.change_state(State.DEAD)
	elif r_cast.is_colliding() and dir.x > 0:
		_fsm.change_state(State.PUNCH_R, [r_cast.get_collider().get_parent()])
	elif l_cast.is_colliding() and dir.x < 0:
		_fsm.change_state(State.PUNCH_R, [l_cast.get_collider().get_parent()])
	elif d_cast.is_colliding() and dir.y > 0:
		_fsm.change_state(State.PUNCH_D, [d_cast.get_collider().get_parent()])
	elif dir.x != 0.0:
		_fsm.change_state(State.WALKING)
	else:
		_fsm.change_state(State.IDLE)


func _enter_punch_d(rock):
	if _punch_d_last_anim == "punch_d1":
		animation_player.play("punch_d2")
		_punch_d_last_anim = "punch_d2"
	else:
		animation_player.play("punch_d1")
		_punch_d_last_anim = "punch_d1"
	_punch_d_rock = rock
	self.fuel -= 1
	punch_sfx.play()


func _process_punch_d():
	if animation_player.is_playing():
		return
	var dir = directional_input.get_input_direction()
	_move(dir)
	_flip_sprite(dir.x)
	var is_grounded = is_on_floor()

	if not is_grounded:
		_fsm.change_state(State.FALLING)
	elif fuel <= 0:
		_fsm.change_state(State.DEAD)
	elif r_cast.is_colliding() and dir.x > 0:
		_fsm.change_state(State.PUNCH_R, [r_cast.get_collider().get_parent()])
	elif l_cast.is_colliding() and dir.x < 0:
		_fsm.change_state(State.PUNCH_R, [l_cast.get_collider().get_parent()])
	elif d_cast.is_colliding() and dir.y > 0:
		_fsm.change_state(State.PUNCH_D, [d_cast.get_collider().get_parent()])
	elif dir.x != 0.0:
		_fsm.change_state(State.WALKING)
	else:
		_fsm.change_state(State.IDLE)


func _enter_falling():
	animation_player.play("idle")


func _process_falling():
	var dir = directional_input.get_input_direction()
	_move(dir)
	_flip_sprite(dir.x)
	var is_grounded = is_on_floor()

	if not is_grounded:
		return
	elif fuel <= 0:
		_fsm.change_state(State.DEAD)
	elif r_cast.is_colliding() and dir.x > 0:
		_fsm.change_state(State.PUNCH_R, [r_cast.get_collider().get_parent()])
	elif l_cast.is_colliding() and dir.x < 0:
		_fsm.change_state(State.PUNCH_R, [l_cast.get_collider().get_parent()])
	elif d_cast.is_colliding() and dir.y > 0:
		_fsm.change_state(State.PUNCH_D, [d_cast.get_collider().get_parent()])
	elif dir.x != 0.0:
		_fsm.change_state(State.WALKING)
	else:
		_fsm.change_state(State.IDLE)


func _enter_walking():
	animation_player.play("walking")


func _process_walking():
	var dir = directional_input.get_input_direction()
	_move(dir)
	_flip_sprite(dir.x)
	var is_grounded = is_on_floor()

	if not is_grounded:
		_fsm.change_state(State.FALLING)
	elif fuel <= 0:
		_fsm.change_state(State.DEAD)
	elif r_cast.is_colliding() and dir.x > 0:
		_fsm.change_state(State.PUNCH_R, [r_cast.get_collider().get_parent()])
	elif l_cast.is_colliding() and dir.x < 0:
		_fsm.change_state(State.PUNCH_R, [l_cast.get_collider().get_parent()])
	elif d_cast.is_colliding() and dir.y > 0:
		_fsm.change_state(State.PUNCH_D, [d_cast.get_collider().get_parent()])
	elif dir.x == 0.0:
		_fsm.change_state(State.IDLE)


func _enter_dead():
	animation_player.play("idle")
	emit_signal("player_died")


func _process_dead():
	_move(Vector2.ZERO)


func _is_grounded() -> bool:
	ground_cast1.force_raycast_update()
	ground_cast2.force_raycast_update()
	return ground_cast1.is_colliding() or ground_cast2.is_colliding()


func _move(dir):
	_velocity.x = dir.x * walk_speed
	_velocity.y += gravity * get_physics_process_delta_time()
	_velocity.y = clamp(_velocity.y, 0, 540)

	var old_position = position.y
	_velocity = move_and_slide(_velocity, Vector2.UP)
	if position.y > old_position:
		emit_signal("depth_changed")


func _flip_sprite(x_input: int) -> void:
	if x_input > 0:
		sprite.flip_h = false
	elif x_input < 0:
		sprite.flip_h = true


func _on_InvulnTimer_timeout():
	sprite_flasher.stop()


func _on_AnimationPlayer_animation_finished(_anim_name):
	if _fsm.state == State.PUNCH_D:
		_punch_d_rock.break_rock(punch_strength[_xp_level], _xp_level)
