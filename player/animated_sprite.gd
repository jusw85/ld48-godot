extends AnimatedSprite


func change_flash(arg):
	material.set_shader_param("flashAmount", arg)
