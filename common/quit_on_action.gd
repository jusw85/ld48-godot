extends Node

export var quit_action := "ui_cancel"


func _unhandled_input(p_event: InputEvent) -> void:
	if (
		p_event.is_action_pressed(quit_action)
		and (OS.get_name() == "Windows" or OS.get_name() == "OSX" or OS.get_name() == "X11")
	):
		get_tree().quit()
		get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
