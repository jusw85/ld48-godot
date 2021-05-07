# https://godotengine.org/qa/438/camera2d-screen-shake-extension
# http://jonny.morrill.me/blog/view/14
extends Node

export var camera2d_path := @".."

var _duration = 0.0
var _shake_delay = 0.0
var _amplitude = 0.0
var _timer = 0.0
var _next_shake_timer = 0
var _previous_target = Vector2.ZERO
var _initial_offset

onready var _camera2d: Camera2D = get_node(camera2d_path)

#var noise
#var noise_y = 0


func _ready():
#	randomize()
#	noise = OpenSimplexNoise.new()
#	noise.seed = randi()
#	noise.period = 8
#	noise.octaves = 2
	set_process(false)


func _process(delta):
	assert(_timer > 0)
#	if _timer <= 0:
#		return

	_next_shake_timer += delta
	while _next_shake_timer >= _shake_delay:
		_next_shake_timer -= _shake_delay

		var intensity = _amplitude * (_timer / _duration)
		var new_target = intensity * Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0))
#		noise_y += 8
#		var new_target = intensity * Vector2(
#			noise.get_noise_2d(noise.seed, noise_y),
#			noise.get_noise_2d(noise.seed * 2, noise_y)
#		)
		var new_offset = lerp(_previous_target, new_target, _shake_delay)
		_camera2d.offset = _initial_offset + new_offset
		_previous_target = new_target

	_timer -= delta
	if _timer <= 0:
		_timer = 0
		_camera2d.offset = _initial_offset
		set_process(false)


func shake(duration, frequency, amplitude):
	if _timer > 0:
		_camera2d.offset = _initial_offset
	_duration = duration
	_timer = duration
	_shake_delay = 1.0 / frequency
	_amplitude = amplitude
	_next_shake_timer = 0.0
	_previous_target = Vector2.ZERO
	_initial_offset = _camera2d.offset
	set_process(true)
#	print(_camera2d.offset)
