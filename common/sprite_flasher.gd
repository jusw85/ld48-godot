# warning-ignore-all:return_value_discarded
extends Node

export var canvas_item_path := @".."
var _is_running = false

onready var _canvas_item: CanvasItem = get_node(canvas_item_path)
onready var _flash_tween: Tween = $FlashTween


func flash(p_duration: float) -> void:
	_is_running = true
	while _is_running:
		_flash_tween.interpolate_property(
			_canvas_item.material, "shader_param/flash_amount", 0.0, 1.0, p_duration
		)
		_flash_tween.start()
		yield(_flash_tween, "tween_all_completed")
		if not _is_running:
			break
		_flash_tween.interpolate_property(
			_canvas_item.material, "shader_param/flash_amount", 1.0, 0.0, p_duration
		)
		_flash_tween.start()
		yield(_flash_tween, "tween_all_completed")


func stop() -> void:
	if _is_running:
		_is_running = false
		_flash_tween.emit_signal("tween_all_completed")
		_flash_tween.remove_all()
		_canvas_item.material.set_shader_param("flash_amount", 0.0)
