extends Node2D


const End := preload("res://gui/end.tscn")
const End2 := preload("res://gui/end2.tscn")

onready var player = $Player
onready var gui_canvas = $GUICanvas
onready var gui = $GUICanvas/GUI


func _ready():
	gui.update_fuel(player.fuel)


func _on_Player_player_died():
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
