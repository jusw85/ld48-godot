extends MarginContainer

onready var fuel_label = $Fuel/Val


func _ready() -> void:
	_update_fuel($"../Player".max_fuel)
	

func _update_fuel(fuel: int) -> void:
	fuel_label.text = str(fuel)


func _on_Player_fuel_changed(fuel: int):
	_update_fuel(fuel)
