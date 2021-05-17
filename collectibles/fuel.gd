extends "res://collectibles/collectible.gd"

export var fuel_pickup_value := 5


func _ready():
	_sprite.play("flash")
	var num_frames = _sprite.frames.get_frame_count("flash")
	_sprite.frame = randi() % num_frames


func _on_collected():
	_player.fuel += fuel_pickup_value
