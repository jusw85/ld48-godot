extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_down"):
		var local = $TileMap.map_to_world(Vector2.ZERO, true)
		var global = $TileMap.to_global(local)
		print(local)
		print(global)
