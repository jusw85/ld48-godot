# warning-ignore-all:return_value_discarded
extends Node2D

# Check light2d
# e.g. draw transparent masks directly on image, with smooth fog blending

# Dust effect on drop
# Tween hud bars
# HUD depth slider on right
# LP: Texture crosshatch shader
# LP: Reorder tilemap ids (fixed in 4.0)

export var darkest_depth := 1600.0
export var hell_depth := 3000.0

var _spawned_hell := false
var _reached_bottom = false
var _is_gameover = false

onready var player = $Player
onready var map = $Map
onready var hud = $GUICanvas/HUD
onready var hell_tween = $HellTween

onready var _darkest_depth = darkest_depth / 10.0
onready var _hell_depth := hell_depth / 10.0


func _ready():
#	get_tree().root.print_stray_nodes()
	Globals.reset()
	Globals.camera = $Camera2D

	Events.connect("hell_spikes_touched", self, "_on_Hell_hell_spikes_touched")
	hud.update_gem(player.gem, 0.0)
	hud.update_fuel(player.fuel, 100.0)

	map.create_rows(10, 0)


func _unhandled_input(event: InputEvent) -> void:
#	if _is_gameover and event.is_action_pressed("restart"):
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()


func _on_Player_player_died():
	_is_gameover = true
	if not _reached_bottom:
		$GUICanvas/OutOfEnergy.visible = true
	else:
		var label = $GUICanvas/DiedInHell
		label.text = "You found %s gems...\nbut at what cost?\n\nPress R to Restart" % player.gem
		label.visible = true


func _on_Player_depth_changed():
	if _reached_bottom:
		return

	var depth = map.get_grid_pos(player.position).y
	player.mask_size = 1.0 - (depth / _darkest_depth)
	hud.update_depth(depth)

	if not _spawned_hell and map.bottom - depth <= 9:
		if map.bottom > _hell_depth:
			_spawned_hell = true
			map.create_hell()
		else:
			map.create_rows(10, map.bottom / 10)


func _on_Hell_hell_spikes_touched():
	_reached_bottom = true
	hud.update_depth(6666, true)
	$GUICanvas/HellTint.visible = true
	$Camera2D.smoothing_speed = 20
	hell_tween.interpolate_property(player, "mask_size", null, 1.0, 0.25)
	hell_tween.interpolate_property($Camera2D, "offset:y", null, -144.0, 0.15)
	hell_tween.start()
