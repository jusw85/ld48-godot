extends Node2D


export var fuel_pickup_value := 1


func _on_Area2D_body_entered(body):
	body.change_fuel(fuel_pickup_value)
	queue_free()
