extends Node2D


export var fuel_pickup_value := 1

onready var sprite: AnimatedSprite = $Area2D/AnimatedSprite
onready var sfx: AudioStreamPlayer = $Sfx

func _ready():
	var num_frames = sprite.frames.get_frame_count("flash")
	sprite.frame = randi() % num_frames


func _on_Area2D_body_entered(body):
	body.change_fuel(fuel_pickup_value)
	sprite.visible = false
	sfx.play()


func _on_Sfx_finished():
	queue_free()
