# warning-ignore-all:return_value_discarded
extends Node2D


const End := preload("res://gui/end.tscn")
const End2 := preload("res://gui/end2.tscn")

onready var player = $Player
onready var gui_canvas = $GUICanvas
onready var gui = $GUICanvas/GUI


func _ready():
	Globals.reset()
	Globals.camera = $Camera2D
	gui.update_fuel(player.fuel)


func _unhandled_input(event: InputEvent) -> void:
	if Globals.is_dead and event.is_action_pressed("restart"):
		get_tree().reload_current_scene()


func _on_Player_player_died():
	Globals.is_dead = true
	if not Globals.is_hell:
		gui_canvas.add_child(End.instance())
	else:
		var end2_inst = End2.instance()
		var label = end2_inst.get_node("Label")
		label.text = (
			"You found "
			+ str(player.gem)
			+ " gems...\nbut at what cost?\n\nPress R to Restart"
		)
		gui_canvas.add_child(end2_inst)
