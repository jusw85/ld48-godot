shader_type canvas_item;
render_mode unshaded;
uniform float flashAmount : hint_range(0.0, 1.0) = 1.0;
uniform vec4 flashColour : hint_color = vec4(1.0);

void fragment() {
	COLOR = texture(TEXTURE, UV);
	COLOR.rgb = mix(COLOR.rgb, flashColour.rgb, flashAmount);
}