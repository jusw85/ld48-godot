extends Node2D

export var dmg := 10
var body

onready var timer: Timer = $Timer


func _on_Area2D_body_entered(p_body):
	self.body = p_body
	body.damage(dmg)
	timer.start()


func _on_Area2D_body_exited(_body):
	timer.stop()


func _on_Timer_timeout():
	body.damage(dmg)
