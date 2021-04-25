extends Node2D


export var gem_pickup_value := 1
export var flash_time := Vector2(2.0, 5.0)

onready var sprite: AnimatedSprite = $Area2D/AnimatedSprite
onready var timer: Timer = $Area2D/Timer


func _ready():
	timer.wait_time = rand_range(flash_time.x, flash_time.y)
	timer.start()


func _on_Area2D_body_entered(body):
	body.change_gem(gem_pickup_value)
	queue_free()


func _on_Timer_timeout():
	sprite.play("flash")


func _on_AnimatedSprite_animation_finished():
	if sprite.animation == "flash":
		sprite.animation = "idle"
