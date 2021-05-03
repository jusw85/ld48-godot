extends Node

export var left_action = "ui_left"
export var right_action = "ui_right"
export var up_action = "ui_up"
export var down_action = "ui_down"
var _last_x_pressed := 1
var _last_y_pressed := 1


func _unhandled_input(p_event: InputEvent) -> void:
	var left_just_pressed := p_event.is_action_pressed(left_action)
	var right_just_pressed := p_event.is_action_pressed(right_action)
	if left_just_pressed:
		_last_x_pressed = -1
	elif right_just_pressed:
		_last_x_pressed = 1

	var up_just_pressed := p_event.is_action_pressed(up_action)
	var down_just_pressed := p_event.is_action_pressed(down_action)
	if up_just_pressed:
		_last_y_pressed = -1
	elif down_just_pressed:
		_last_y_pressed = 1


func get_input_direction() -> Vector2:
	var x: float
	var left_pressed := Input.is_action_pressed(left_action)
	var right_pressed := Input.is_action_pressed(right_action)
	if left_pressed and not right_pressed:
		x = -1
	elif not left_pressed and right_pressed:
		x = 1
	elif left_pressed and right_pressed:
		x = _last_x_pressed
	else:
		x = 0

	var y: float
	var up_pressed := Input.is_action_pressed(up_action)
	var down_pressed := Input.is_action_pressed(down_action)
	if up_pressed and not down_pressed:
		y = -1
	elif not up_pressed and down_pressed:
		y = 1
	elif up_pressed and down_pressed:
		y = _last_y_pressed
	else:
		y = 0
	return Vector2(x, y)
