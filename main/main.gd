# warning-ignore-all:return_value_discarded
extends Node2D

onready var is_gameover = false
onready var is_hell = false
onready var player = $Player
onready var map = $Map
onready var hud = $GUICanvas/HUD
onready var end_tween = $HellTween


# TODO: exit tree, queue free for add_child to cleanup
func _ready():
	Globals.reset()
	Globals.camera = $Camera2D
	Events.connect("hell_spikes_touched", self, "_on_Hell_hell_spikes_touched")
	hud.update_fuel(player.fuel)


func _unhandled_input(event: InputEvent) -> void:
	if is_gameover and event.is_action_pressed("restart"):
		get_tree().reload_current_scene()


func _on_Player_player_died():
	is_gameover = true
	if not is_hell:
		$GUICanvas/OutOfEnergy.visible = true
	else:
		var label = $GUICanvas/DiedInHell
		label.text = "You found %s gems...\nbut at what cost?\n\nPress R to Restart" % player.gem
		label.visible = true


func _on_Player_depth_changed():
	if not is_hell:
		var grid_pos = map.get_grid_pos(player.position)
		var depth = grid_pos.y
		player.mask_size = 1.0 - (depth / 160.0)
		map.check_create_map(depth)
		hud.update_depth(depth)


func _on_Hell_hell_spikes_touched():
	is_hell = true
	hud.update_depth(6666, true)
	$GUICanvas/HellTint.visible = true
	end_tween.interpolate_property(player, "mask_size", null, 1.0, 0.25)
	end_tween.interpolate_property($Camera2D, "offset:y", null, -144.0, 0.15)
	end_tween.start()


# to listen to rock_break
#func _rock_break() -> void:
#	pass
#	shake camera
