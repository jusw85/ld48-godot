extends Node2D


func _on_Area2D_body_entered(body):
	assert(body.name == "Player")
	Events.emit_signal("hell_spikes_touched")
