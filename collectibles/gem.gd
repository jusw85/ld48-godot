extends Node2D

export var gem_pickup_value := 1
export var flash_time := Vector2(2.0, 5.0)

onready var sprite: AnimatedSprite = $Area2D/AnimatedSprite
onready var timer: Timer = $Timer
onready var sfx: AudioStreamPlayer = $Sfx
onready var collider: CollisionShape2D = $Area2D/CollisionShape2D


func _ready():
	timer.wait_time = rand_range(flash_time.x, flash_time.y)
	timer.start()


#func _on_Area2D_body_entered(body):
#	body.gem += gem_pickup_value
#	sprite.visible = false
#	collider.set_deferred("disabled", true)
#	sfx.play()


func _on_Timer_timeout():
	sprite.play("flash")


func _on_AnimatedSprite_animation_finished():
	if sprite.animation == "flash":
		sprite.animation = "idle"


func _on_Sfx_finished():
	queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_Area2D_area_entered(area):
	area.get_parent().gem += gem_pickup_value
	sprite.visible = false
	collider.set_deferred("disabled", true)
	sfx.play()
