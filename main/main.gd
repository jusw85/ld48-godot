# warning-ignore-all:return_value_discarded
extends Node2D

export var darkest_depth := 1600.0

onready var _darkest_depth = darkest_depth / 10.0
onready var _is_gameover = false
onready var _is_hell = false

onready var player = $Player
onready var map = $Map
onready var hud = $GUICanvas/HUD
onready var end_tween = $HellTween


# TODO: exit tree, queue free for add_child to cleanup
func _ready():
#	get_tree().root.print_stray_nodes()
	player.mask_size = 1.0
	Globals.reset()
	Globals.camera = $Camera2D
	Events.connect("hell_spikes_touched", self, "_on_Hell_hell_spikes_touched")
	hud.update_fuel(player.fuel)


func _unhandled_input(event: InputEvent) -> void:
	if _is_gameover and event.is_action_pressed("restart"):
		get_tree().reload_current_scene()


func _on_Player_player_died():
	_is_gameover = true
	if not _is_hell:
		$GUICanvas/OutOfEnergy.visible = true
	else:
		var label = $GUICanvas/DiedInHell
		label.text = "You found %s gems...\nbut at what cost?\n\nPress R to Restart" % player.gem
		label.visible = true


func _on_Player_depth_changed():
	if not _is_hell:
#		var depth = map.get_grid_pos(player.position).y
		var depth = player.position.y / 64.0
		player.mask_size = 1.0 - (depth / _darkest_depth)
		map.check_create_map(depth)
		hud.update_depth(depth)


func _on_Hell_hell_spikes_touched():
	_is_hell = true
	hud.update_depth(6666, true)
	$GUICanvas/HellTint.visible = true
	$Camera2D.smoothing_speed = 20
	end_tween.interpolate_property(player, "mask_size", null, 1.0, 0.25)
	end_tween.interpolate_property($Camera2D, "offset:y", null, -144.0, 0.15)
	end_tween.start()


# to listen to rock_break
#func _rock_break() -> void:
#	pass
#	shake camera
