shader_type canvas_item;
render_mode unshaded;

uniform float flash_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec4 flash_colour : hint_color = vec4(1.0);

void fragment() {
	COLOR = texture(TEXTURE, UV);
	COLOR.rgb = mix(COLOR.rgb, flash_colour.rgb, flash_amount);
}