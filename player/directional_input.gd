extends Node


var last_x_pressed := 1
var last_y_pressed := 1


func _unhandled_input(event: InputEvent) -> void:
	var left_just_pressed := event.is_action_pressed("ui_left")
	var right_just_pressed := event.is_action_pressed("ui_right")
	if left_just_pressed:
		last_x_pressed = -1
	elif right_just_pressed:
		last_x_pressed = 1
		
	var up_just_pressed := event.is_action_pressed("ui_up")
	var down_just_pressed := event.is_action_pressed("ui_down")
	if up_just_pressed:
		last_y_pressed = -1
	elif down_just_pressed:
		last_y_pressed = 1


func get_input() -> Vector2:
	var x: float
	var left_pressed := Input.is_action_pressed("ui_left")
	var right_pressed := Input.is_action_pressed("ui_right")
	if left_pressed and not right_pressed:
		x = -1
	elif not left_pressed and right_pressed:
		x = 1
	elif left_pressed and right_pressed:
		x = last_x_pressed
	else:
		x = 0
		
	var y: float
	var up_pressed := Input.is_action_pressed("ui_up")
	var down_pressed := Input.is_action_pressed("ui_down")
	if up_pressed and not down_pressed:
		y = -1
	elif not up_pressed and down_pressed:
		y = 1
	elif up_pressed and down_pressed:
		y = last_y_pressed
	else:
		y = 0
	return Vector2(x, y)
