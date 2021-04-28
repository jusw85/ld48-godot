extends Node2D


func _ready():
	$GUICanvas/GUI.update_fuel($Player.fuel)
