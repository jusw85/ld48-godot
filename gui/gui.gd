extends MarginContainer

onready var fuel_label: Label = $VBoxContainer/Fuel/Val
onready var gem_label: Label = $VBoxContainer/Gem/Val
onready var depth_label: Label = $VBoxContainer/Depth/Val


func update_fuel(fuel: int) -> void:
	fuel_label.text = str(fuel)


func _on_Player_fuel_changed(fuel: int):
	update_fuel(fuel)


func _on_Player_gem_changed(gem: int):
	gem_label.text = str(gem)


func _on_Player_depth_changed(depth: int):
	depth_label.text = str(depth * 10) + " feet"
