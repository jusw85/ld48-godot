extends "res://collectibles/collectible.gd"


export var gem_pickup_value := 1
export var flash_time := Vector2(2.0, 5.0)

onready var _timer: Timer = $Timer


func _ready():
	_sprite.play("idle")
	_timer.wait_time = rand_range(flash_time.x, flash_time.y)
	_timer.start()


func _on_Timer_timeout():
	_sprite.play("flash")


func _on_AnimatedSprite_animation_finished():
	if _sprite.animation == "flash":
		_sprite.animation = "idle"


func _on_collected():
	_player.gem += gem_pickup_value
