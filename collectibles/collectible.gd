# warning-ignore-all:return_value_discarded
extends Node2D

var _player

onready var _sprite: AnimatedSprite = $AnimatedSprite
onready var _sfx: AudioStreamPlayer = $Sfx
onready var _collider: CollisionShape2D = $CollisionShape2D
onready var _tween: Tween = $Tween


func _on_Sfx_finished():
	queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_Collectible_area_entered(area):
	if _player == null:
		_player = area.get_parent()
		_tween.follow_method(
			self, "set_global_position", global_position, _player, "get_global_position", 0.1
		)
		_tween.start()


func _on_Tween_tween_all_completed():
	_on_collected()
	_sprite.visible = false
	_collider.set_deferred("disabled", true)
	_sfx.play()


func _on_collected():
	pass
