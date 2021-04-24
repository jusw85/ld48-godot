extends MarginContainer

onready var fuel_label = $VBoxContainer/Fuel/Val
onready var gem_label = $VBoxContainer/Gem/Val


func _ready() -> void:
	_update_fuel($"../../Player".start_fuel)
	

func _update_fuel(fuel: int) -> void:
	fuel_label.text = str(fuel)


func _on_Player_fuel_changed(fuel: int):
	_update_fuel(fuel)


func _on_Player_gem_changed(gem: int):
	gem_label.text = str(gem)
