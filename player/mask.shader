shader_type canvas_item;

const vec2 mid = vec2(0.5);
//uniform float dist: hint_range(0.1, 1.0)  = 0.3;

uniform float val: hint_range(0.0, 1.0)  = 1.0;
uniform float l = 0.0;
uniform float r = 0.0;
uniform float scale = 0.0;

void fragment() {
//	float l = log(0.1);
//	float r = log(1.0);
//	float scale = r - l / (1.0 - 0.0);
	
//	float dist = 1.0;
	float dist = exp(l + scale * (val - 0.0));
	float a = distance(UV, mid) / dist;
	vec3 c = vec3(0.0);
	COLOR = vec4(c, a);
}
