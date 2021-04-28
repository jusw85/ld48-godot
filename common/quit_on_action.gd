extends Node


export var quit_action := "ui_cancel"


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(quit_action) and \
			(OS.get_name() == "Windows" or
			OS.get_name() == "OSX" or
			OS.get_name() == "X11"):
		get_tree().quit()
