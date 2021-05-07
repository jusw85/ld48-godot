extends Node2D

onready var camera = $Camera2D
onready var shake = $Camera2D/Shake


func _ready():
	pass


func _draw():
	draw_rect(Rect2(Vector2(-50, -50), Vector2(100, 100)), Color.white)


func _physics_process(_delta):
	if Input.is_action_just_pressed("ui_right"):
		shake.shake(0.05, 100.0, 5.0)
#		shake.shake(0.10, 100.0, 8.0)
