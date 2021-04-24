extends Node2D


export var gem_pickup_value := 1


func _on_Area2D_body_entered(body):
	body.change_gem(gem_pickup_value)
	queue_free()
