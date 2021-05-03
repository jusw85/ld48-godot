extends Node2D

export var dmg := 10
onready var timer: Timer = $Timer
var body


func _on_Area2D_body_entered(body):
	self.body = body
	body.damage(dmg)
	timer.start()


func _on_Area2D_body_exited(_body):
	timer.stop()


func _on_Timer_timeout():
	body.damage(dmg)
