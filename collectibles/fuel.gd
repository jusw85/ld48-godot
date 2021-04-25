extends Node2D


export var fuel_pickup_value := 1

onready var sprite: AnimatedSprite = $Area2D/AnimatedSprite

func _ready():
	var num_frames = sprite.frames.get_frame_count("flash")
	sprite.frame = randi() % num_frames


func _on_Area2D_body_entered(body):
	body.change_fuel(fuel_pickup_value)
	queue_free()
