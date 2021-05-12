extends MarginContainer

onready var fuel_label: Label = $VBoxContainer/Fuel/Val
onready var gem_label: Label = $VBoxContainer/Gem/Val
onready var depth_label: Label = $VBoxContainer/Depth/Val


func update_fuel(fuel: int) -> void:
	fuel_label.text = str(fuel)


func update_gem(gem: int):
	gem_label.text = str(gem)


func update_depth(depth: int, force: bool = false) -> void:
	var d = depth if force else depth * 10
	depth_label.text = str(d) + " feet"
