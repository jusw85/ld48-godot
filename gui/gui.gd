extends MarginContainer

onready var fuel_label = $VBoxContainer/Fuel/Val
onready var gem_label = $VBoxContainer/Gem/Val
onready var depth_label = $VBoxContainer/Depth/Val


func _ready() -> void:
	_update_fuel($"../../Player".start_fuel)


func _update_fuel(fuel: int) -> void:
	fuel_label.text = str(fuel)


func _on_Player_fuel_changed(fuel: int):
	_update_fuel(fuel)


func _on_Player_gem_changed(gem: int):
	gem_label.text = str(gem)


func _on_Player_depth_changed(depth: int):
	depth_label.text = str((depth + 1) * 10) + " feet"
