extends AudioStreamPlayer

onready var tween_out = get_node("TweenOut")
onready var tween_in = get_node("TweenIn")

export var transition_duration = 2.00
export var transition_type = 1 # TRANS_SINE

var next_song: AudioStream

func next_song(next: AudioStream):
	next_song = next

func fade_out():
	tween_out.interpolate_property(self, "volume_db", 0, -80, transition_duration, transition_type, Tween.EASE_IN, 0)
	tween_out.start()

func fade_in():
	tween_in.interpolate_property(self, "volume_db", -80, 0, transition_duration, transition_type, Tween.EASE_IN, 0)
	tween_in.start()

func _on_TweenOut_tween_completed(_object, _key):
	stop()
	if next_song != null:
		stream = next_song
		play()
		volume_db = 0
#		fade_in()
