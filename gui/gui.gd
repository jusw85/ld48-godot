# https://github.com/godotengine/godot-proposals/issues/1754
extends MarginContainer

onready var depth_label: Label = $VBoxContainer/Depth/Val
onready var gem_label: Label = $VBoxContainer/Gem/Control/Control/Val
onready var gem_sprite: AnimatedSprite = $VBoxContainer/Gem/Icon/AnimatedSprite
onready var gem_bar: TextureProgress = $VBoxContainer/Gem/Control/TextureProgress
onready var fuel_label: Label = $VBoxContainer/Fuel/Control/Control/Val
onready var fuel_sprite: AnimatedSprite = $VBoxContainer/Fuel/Icon/AnimatedSprite
onready var fuel_bar: TextureProgress = $VBoxContainer/Fuel/Control/TextureProgress


func _ready():
	fuel_sprite.playing = true
	gem_bar.tint_progress = Color("#dd9422")
#	gem_bar.tint_progress = gem_bar.tint_under.lightened(0.2)
#	fuel_bar.tint_progress = fuel_bar.tint_under.darkened(0.2)



func update_fuel(fuel: int, fuel_percentage: float) -> void:
	fuel_label.text = "Fuel: " + str(fuel)
	fuel_bar.value = fuel_percentage


func update_gem(gem: int, level_percentage: float):
	gem_label.text = "Gems: " + str(gem)
	gem_bar.value = level_percentage


func update_depth(depth: int, force: bool = false) -> void:
	var d = depth if force else depth * 10
	depth_label.text = str(d) + " feet"


func _on_Timer_timeout():
	gem_sprite.play("flash")


func _on_AnimatedSprite_animation_finished():
	if gem_sprite.animation == "flash":
		gem_sprite.animation = "idle"


func _on_Player_level_changed(level):
#	gem_bar.tint_under = gem_bar.tint_progress
#	gem_bar.tint_progress = gem_bar.tint_under.lightened((0.2))
	match level:
		1:
			gem_bar.tint_under = gem_bar.tint_progress
			gem_bar.tint_progress = Color("#dd491c")
		2:
			gem_bar.tint_under = gem_bar.tint_progress
			gem_bar.tint_progress = Color("#fb8008")
		3:
			pass
