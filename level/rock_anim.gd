extends Node2D


onready var sprite: AnimatedSprite = $AnimatedSprite


func start(anim: String):
	sprite.play(anim)


func _on_AnimatedSprite_animation_finished():
	queue_free()
