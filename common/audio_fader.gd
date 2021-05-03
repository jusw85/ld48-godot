# warning-ignore-all:return_value_discarded
extends Node

export var audio_stream_path := @".."
export var transition_duration = 2.00

onready var _audio_stream: AudioStreamPlayer = get_node(audio_stream_path)
onready var _fade_out_tween: Tween = $FadeOutTween
onready var _fade_in_tween: Tween = $FadeInTween


func fade_out() -> void:
	_fade_out_tween.stop_all()
	_fade_out_tween.interpolate_property(
		_audio_stream, "volume_db", 0, -80, transition_duration, Tween.TRANS_SINE, Tween.EASE_IN, 0
	)
	_fade_out_tween.start()


func fade_in() -> void:
	_fade_in_tween.stop_all()
	_fade_in_tween.interpolate_property(
		_audio_stream, "volume_db", -80, 0, transition_duration, Tween.TRANS_SINE, Tween.EASE_IN, 0
	)
	_fade_in_tween.start()
