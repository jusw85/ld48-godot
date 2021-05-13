extends AudioStreamPlayer

export (Array, AudioStream) var bgms
var _current_bgm := 0

onready var _audio_fader: NC.AudioFader = $AudioFader


func _ready():
	_play_current_bgm()


func _play_current_bgm():
	if _current_bgm < bgms.size():
		stream = bgms[_current_bgm]
		play()


func _on_Player_level_changed(_level):
	_audio_fader.fade_out()


func _on_FadeOutTween_tween_all_completed():
	stop()
	_current_bgm += 1
	_play_current_bgm()
	volume_db = 0
