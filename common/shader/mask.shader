shader_type canvas_item;
render_mode unshaded;

const vec2 mid = vec2(0.5);
uniform float size: hint_range(0.0, 1.0)  = 1.0; // slider_val

//https://www.dr-lex.be/info-stuff/volumecontrols.html
//https://stackoverflow.com/questions/846221/logarithmic-slider
const float slider_left = 0.0;
const float slider_right = 1.0;
const float target_left = 0.1;
const float target_right = 1.0;
// workaround
// https://github.com/godotengine/godot/issues/48204
const float log_target_left = log(target_left) + 0.0; 
const float log_target_right = log(target_right) + 0.0;
const float scale = (log_target_right - log_target_left) / (slider_right - slider_left);

void fragment() {
	float dist = exp(log_target_left + scale * (size - slider_left));
	float a = distance(UV, mid) / dist;
	a = clamp(a, 0.0, 1.0);
	vec3 c = vec3(0.0);
	COLOR = vec4(c, a);
}
