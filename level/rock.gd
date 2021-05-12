extends Node2D

# global signal handler
signal rock_broken

const RockBreak := preload("res://level/rock_anim.tscn")
onready var sprite: Sprite = $StaticBody2D/Sprite
# TODO: positional crumble audio


func start(id: int):
	sprite.frame = id


func _ready():
#	print(name)
	pass  # Replace with function body.


#	connect("rock_broken", $"../", "_zz")

#func _unhandled_input(event):
#	if event.is_action_pressed("ui_up"):
##		break_block()
#		break_rock()


func break_block():
	print("BREAKING!")
	emit_signal("rock_broken") # camera shake


#func is_rock(p_grid_pos: Vector2) -> bool:
#	var tile_id := tilemap.get_cellv(p_grid_pos)
#	var autotile_id := tilemap.get_cell_autotile_coord(int(p_grid_pos.x), int(p_grid_pos.y))
#	return tile_id == 4 and autotile_id.x <= 7 and autotile_id.x >= 1
#
#
## use objects for rocks?
## object destroyer above player
func break_rock(p_dmg: int, p_level: int):
	var rock_id := sprite.frame
	var new_rock_id = rock_id - p_dmg
	for i in [1, 3, 5, 7]:
		if i in range(new_rock_id + 1, rock_id + 1):
			_spawn_rockbreak(i, p_level)

	if new_rock_id < 1:
		$CrumbleSfx.play()
		sprite.visible = false
		$StaticBody2D/CollisionShape2D.disabled = true
#		use this in physics process
#		$StaticBody2D/CollisionShape2D.set_deferred("disabled", true)
	else:
		sprite.frame = new_rock_id


func _spawn_rockbreak(num: int, p_level: int) -> void:
#	emit_signal here
	if p_level == 2:
		Globals.camera.get_node("Shake").shake(0.05, 100.0, 5.0)
	elif p_level == 3:
		Globals.camera.get_node("Shake").shake(0.10, 100.0, 8.0)

	var rb = RockBreak.instance()
#	get_parent().add_child(rb)
#	check queue_free on crumble
	add_child(rb)  # check queue_free
	rb.position.x += rand_range(-16, 16)
	rb.position.y += rand_range(-16, 16)
	rb.start("crumble" + str(num))


func _on_CrumbleSfx_finished():
	pass
#	queue_free()
