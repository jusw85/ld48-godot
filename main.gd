extends Node2D


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and \
			(OS.get_name() == "Windows" or
			OS.get_name() == "OSX" or
			OS.get_name() == "X11"):
		get_tree().quit()

