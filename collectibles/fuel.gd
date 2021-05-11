extends Node2D

export var fuel_pickup_value := 1

onready var sprite: AnimatedSprite = $Area2D/AnimatedSprite
onready var sfx: AudioStreamPlayer = $Sfx
onready var collider: CollisionShape2D = $Area2D/CollisionShape2D


func _ready():
	var num_frames = sprite.frames.get_frame_count("flash")
	sprite.frame = randi() % num_frames


func _on_Area2D_body_entered(body):
	body.fuel += fuel_pickup_value
	sprite.visible = false
	collider.set_deferred("disabled", true)
	sfx.play()


func _on_Sfx_finished():
	queue_free()


func _on_VisibilityNotifier2D_screen_exited():
#	print("!")
	queue_free()


func _on_Area2D_area_entered(area):
	area.get_parent().fuel += fuel_pickup_value
	sprite.visible = false
	collider.set_deferred("disabled", true)
	sfx.play()
