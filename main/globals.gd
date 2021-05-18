extends Node

var camera: Camera2D = null
var tile_probability = []
var rock_probability = []

var _config


func reset():
	camera = null


func _init():
	_config = ConfigFile.new()
#	.ini doesn't show in filesystem dock
#	https://github.com/godotengine/godot-proposals/issues/677
	var err = _config.load("res://config/difficulty.tres")
	assert(err == OK)

	var tile_probability_single = _config.get_value("difficulty", "tile_probability")
	for row in tile_probability_single:
		tile_probability.append(_cumulate(row))

	var rock_probability_single = _config.get_value("difficulty", "rock_probability")
	for row in rock_probability_single:
		rock_probability.append(_cumulate(row))


func _cumulate(arr: Array) -> Array:
	if arr.empty():
		return []
	var res = [arr[0]]
	for x in range(1, arr.size()):
		res.append(res[x - 1] + arr[x])
	return res
