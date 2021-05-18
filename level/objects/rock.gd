extends Node2D

const RockBreak := preload("res://level/objects/rock_anim.tscn")

onready var sprite: Sprite = $StaticBody2D/Sprite


func init(id: int):
	sprite.frame = id


func break_rock(p_dmg: int, p_level: int):
	var rock_id := sprite.frame
	var new_rock_id = rock_id - p_dmg
	for i in [1, 3, 5, 7]:
		if i in range(new_rock_id + 1, rock_id + 1):
			_spawn_rockbreak(i, p_level)

	if new_rock_id < 1:
		$CrumbleSfx.play()
		sprite.visible = false
#		$StaticBody2D/CollisionShape2D.disabled = true
		$StaticBody2D/CollisionShape2D.set_deferred("disabled", true)
	else:
		sprite.frame = new_rock_id


func _spawn_rockbreak(num: int, p_level: int) -> void:
#	maybe emit_signal here to reduce coupling, easier testing
	if p_level == 2:
		Events.emit_signal("camera_shake", 0.05, 100.0, 5.0)
#		Globals.camera.get_node("Shake").shake(0.05, 100.0, 5.0)
	elif p_level == 3:
		Events.emit_signal("camera_shake", 0.10, 100.0, 8.0)
#		Globals.camera.get_node("Shake").shake(0.10, 100.0, 8.0)

	var rb = RockBreak.instance()
	add_child(rb)
	rb.position.x += rand_range(-16, 16)
	rb.position.y += rand_range(-16, 16)
	rb.start("crumble" + str(num))


func _on_CrumbleSfx_finished():
	pass
#	in case crumble hasn't finished, let visibility notifier take care of cleanup
#	queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
