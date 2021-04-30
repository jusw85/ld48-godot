extends KinematicBody2D


# lerp global camera
# move tilemap out
# fix depth
# reorder tilemap
# positional audio for punch
# tighten controls
# collectible AOE fly to player
# dust effect on drop


signal fuel_changed(fuel)
signal gem_changed(gem)
signal depth_changed(depth)
signal level_changed(level)

enum States {IDLE, DEAD, WALKING, FALLING, PUNCH_R, PUNCH_D}
var state = States.IDLE

const End := preload("res://gui/end.tscn")
const End2 := preload("res://gui/end2.tscn")
const RockBreak := preload("res://level/rock_anim.tscn")

export var walk_speed := 600.0
export var gravity := 500.0
export var start_fuel := 30
export var xp_to_level := [2, 4, 6]
export var punch_strength := [1, 2, 3, 4]

var depth := -1
var xp_level := 0
var to_del_downpunch: NC.TileMapUtils.TileInfo
var cam_left_x: float
var cam_right_x: float

onready var gem := 0 setget gem_set
onready var fuel := start_fuel setget fuel_set
onready var level = $"../Level"
onready var tilemap: TileMap = $"../Level/TileMap"
onready var directional_input: NC.DirectionalInput = $DirectionalInput
onready var ground_cast: RayCast2D = $GroundCast
onready var r_cast: RayCast2D = $RightCast
onready var l_cast: RayCast2D = $LeftCast
onready var sprite: AnimatedSprite = $AnimatedSprite
onready var mask: Sprite = $Mask
onready var camera: Camera2D = $Camera2D
onready var player_frames = [ \
	preload("res://player/player0.tres"), \
	preload("res://player/player1.tres"), \
	preload("res://player/player2.tres"), \
	preload("res://player/player3.tres")]

onready var punch_sfx: AudioStreamPlayer = $PunchSfx
onready var crumble_sfx: AudioStreamPlayer = $CrumbleSfx
onready var invuln_timer: Timer = $InvulnTimer
onready var flash_tween: Tween = $FlashTween


func _ready() -> void:
	cam_left_x = tilemap.to_global(tilemap.map_to_world(level.bounds_min)).x
	cam_right_x = tilemap.to_global(tilemap.map_to_world(level.bounds_max)).x + 64
	camera.limit_left = cam_left_x
	camera.limit_right = cam_right_x


func _unhandled_input(event: InputEvent) -> void:
	if state == States.DEAD:
		if event.is_action_pressed("restart"):
			get_tree().reload_current_scene()
		else:
			return

func gem_set(val: int) -> void:
	gem = int(max(val, 0))
	emit_signal("gem_changed", gem)
	if xp_level < xp_to_level.size() and gem >= xp_to_level[xp_level]:
		xp_level += 1
		sprite.frames = player_frames[xp_level]
		emit_signal("level_changed", xp_level)


func fuel_set(val: int) -> void:
	fuel = int(max(val, 0))
	emit_signal("fuel_changed", fuel)
#	if fuel <= 0:
#		state = States.DEAD
#		$"../GUI".add_child(End.instance())

func _process(_delta) -> void:
	if position.x < cam_left_x + 64:
		camera.limit_left = position.x - 64
	else:
		camera.limit_left = cam_left_x

	if position.x > cam_right_x - 64:
		camera.limit_right = position.x + 64
	else:
		camera.limit_right = cam_right_x

func _physics_process(_delta) -> void:
	if state == States.PUNCH_R:
		assert(sprite.animation == "punchright")
		return
	elif state == States.PUNCH_D:
		assert(sprite.animation == "punchdown")
		return

	var is_grounded = ground_cast.is_colliding()
	if fuel <= 0 and is_grounded:
		sprite.animation = "idle"
		state = States.DEAD
		if not is_hell:
			$"../GUICanvas".add_child(End.instance())
		else:
			var end2_inst = End2.instance()
			var label = end2_inst.get_node("Label")
			label.text = "You found " + str(gem) + " gems...\nbut at what cost?\n\nPress R to Restart"
			$"../GUICanvas".add_child(end2_inst)
		return

	var dir = directional_input.get_input_direction()
	if state == States.DEAD:
		dir = Vector2.ZERO

	var velocity = Vector2()
	velocity.x = dir.x * walk_speed
	velocity.y += gravity
	velocity.y = clamp(velocity.y, 0, INF)
	move_and_slide(velocity)

	_check_depth()

	if is_grounded and r_cast.is_colliding() and dir.x > 0:
		var pos := r_cast.get_collision_point()
		pos.x += 1
		if level.try_break_rock(pos, punch_strength[xp_level]):
			self.fuel -= 1
			punch_sfx.play()
			state = States.PUNCH_R

	if state == States.IDLE and is_grounded and l_cast.is_colliding() and dir.x < 0:
		var pos := l_cast.get_collision_point()
		pos.x -= 1
		if level.try_break_rock(pos, punch_strength[xp_level]):
			self.fuel -= 1
			punch_sfx.play()
			state = States.PUNCH_R

	if state == States.IDLE and is_grounded and dir.y > 0:
		var pos := ground_cast.get_collision_point()
		pos.y += 1

		var tileinfo := NC.TileMapUtils.global_pos_to_tileinfo(tilemap, pos)
		if tileinfo.tile_id == 4 and tileinfo.autotile_id.x <= 7:
			punch_sfx.play()
			self.fuel -= 1
			state = States.PUNCH_D
			to_del_downpunch = tileinfo

	if state == States.DEAD:
		sprite.play("idle")
	else:
		if state == States.PUNCH_R:
			sprite.play("punchright")
		elif state == States.PUNCH_D:
			sprite.play("punchdown")
		elif is_grounded and velocity.x != 0.0:
			sprite.play("walking")
		else:
			sprite.play("idle")
	_flip_sprite(dir.x)

func _check_depth() -> void:
	if is_hell:
		return
	var new_depth = tilemap.world_to_map(tilemap.to_local(global_position)).y
	if new_depth != depth:
#		0 - 160
#		0.1 - 1.0
#		var minv = log(0.1)
#		var maxv = log(1.0)
#		exp(s)
#		https://stackoverflow.com/questions/846221/logarithmic-slider

#		var ma = clamp(1.0 - (new_depth / 100.0), 0.1, 1.0)
#		mask.material.set_shader_param("dist", ma)

		var ma = clamp(1.0 - (new_depth / 160.0), 0.0, 1.0)
		mask.material.set_shader_param("size", ma)

		depth = new_depth
		level.check_create_map(depth)
		emit_signal("depth_changed", depth)



func _flip_sprite(x_input: int) -> void:
	if x_input > 0:
		sprite.flip_h = false
	elif x_input < 0:
		sprite.flip_h = true


func _on_AnimatedSprite_animation_finished():
	if sprite.animation == "punchright":
		sprite.animation = "idle"
		state = States.IDLE
	elif sprite.animation == "punchdown":
		var tileinfo = to_del_downpunch

		var rock_id := int(tileinfo.autotile_id.x)
		var new_rock_id = rock_id - punch_strength[xp_level]
		if new_rock_id < 7 and 7 <= rock_id:
			_spawn_rockbreak(tileinfo, 7)
		if new_rock_id < 5 and 5 <= rock_id:
			_spawn_rockbreak(tileinfo, 5)
		if new_rock_id < 3 and 3 <= rock_id:
			_spawn_rockbreak(tileinfo, 3)
		if new_rock_id < 1 and 1 <= rock_id:
			_spawn_rockbreak(tileinfo, 1)

		if new_rock_id < 1:
			crumble_sfx.play()
			tilemap.set_cellv(tileinfo.grid_pos, -1)
		else:
			var new_autotile = Vector2(new_rock_id, tileinfo.autotile_id.y)
			tilemap.set_cell(tileinfo.grid_pos.x, tileinfo.grid_pos.y, \
				tileinfo.tile_id, false, false, false, new_autotile)

		sprite.animation = "idle"
		state = States.IDLE

func damage(dmg: int):
	if state == States.DEAD:
		return
	if invuln_timer.time_left <= 0:
		self.fuel -= dmg
		invuln_timer.start()
		while invuln_timer.time_left > 0:
			flash_tween.interpolate_property(sprite.material, "shader_param/flash_amount", 0.0, 1.0, 0.25)
			flash_tween.start()
			yield(flash_tween, "tween_all_completed")
			flash_tween.interpolate_property(sprite.material, "shader_param/flash_amount", 1.0, 0.0, 0.25)
			flash_tween.start()
			yield(flash_tween, "tween_all_completed")

var is_hell = false
func do_hell():
	is_hell = true
	emit_signal("depth_changed", 665)
	$Mask2.visible = true
	var mask_tween = $MaskTween
	mask_tween.interpolate_property(mask.material, "shader_param/size", mask.material.get_shader_param("size"), 1.0, 0.25)
	mask_tween.start()

	var camera_tween = $CameraTween
	camera_tween.interpolate_property(camera, "offset:y", null, -144.0, 0.15)
	camera_tween.start()


func _spawn_rockbreak(tileinfo: NC.TileMapUtils.TileInfo, num: int) -> void:
	if xp_level == 2:
		camera.shake(0.05, 25.0, 5.0)
	elif xp_level == 3:
		camera.shake(0.1, 25.0, 10.0)
	var rb = RockBreak.instance()
	tilemap.add_child(rb)
	rb.position = tilemap.map_to_world(tileinfo.grid_pos)
	rb.position.x += rand_range(-16, 16)
	rb.position.y += rand_range(-16, 16)
	rb.start("crumble" + str(num))
