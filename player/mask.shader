shader_type canvas_item;

const vec2 mid = vec2(0.5);
uniform float dist = 0.3;

void fragment() {
	float a = distance(UV, mid) / dist;
	vec3 c = vec3(0.0);
	COLOR = vec4(c, a);
}
