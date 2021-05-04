// https://ldjam.com/events/ludum-dare/48/autumn-hike/autumn-hike-dithering-explained
// https://gist.github.com/kolen/d52d173f484a68c3c0e723b8719618f7
// https://medium.com/the-bkpt/dithered-shading-tutorial-29f57d06ac39
// https://en.wikipedia.org/wiki/Ordered_dithering
// https://github.com/SixLabors/ImageSharp/blob/master/src/ImageSharp/Processing/Processors/Dithering/DHALF.TXT
// https://bisqwit.iki.fi/story/howto/dither/jy/
shader_type canvas_item;
uniform float r = 0.5;

//const mat4 m = mat4(
//	vec4(1, 9, 3, 11) / 17.0,
//	vec4(13, 5, 15, 7) / 17.0,
//	vec4(4, 12, 2, 10) / 17.0,
//	vec4(16, 8, 14, 6) / 17.0
//);

const mat4 m = mat4(
	(vec4(1, 9, 3, 11) / 16.0) - 0.5,
	(vec4(13, 5, 15, 7) / 16.0) - 0.5,
	(vec4(4, 12, 2, 10) / 16.0) - 0.5,
	(vec4(16, 8, 14, 6) / 16.0) - 0.5
);

// https://github.com/godotengine/godot-proposals/issues/2175
//float idx_mat4_2d(mat4 m, int y, int x) {
float idx_mat4_2d(int y, int x) {
	vec4 v;
	if (y == 0) {
		v = m[0];
	} else if (y == 1) {
		v = m[1];
	} else if (y == 2) {
		v = m[2];
	} else if (y == 3) {
		v = m[3];
	}
	float val;
	if (x == 0) {
		val = v[0];
	} else if (x == 1) {
		val = v[1];
	} else if (x == 2) {
		val = v[2];
	} else if (x == 3) {
		val = v[3];
	}
	return val;
}

//void fragment() {
//	vec3 rgb = texture(TEXTURE, UV).rgb;
//
//	vec2 xy_offset = mod(FRAGCOORD.xy, vec2(4.0, 4.0));
//	int x = int(xy_offset.x);
//	int y = int(xy_offset.y);
//
//	float threshold = idx_mat4_2d(y, x);
//	COLOR.rgb = step(vec3(threshold), rgb);
////	COLOR = texture(TEXTURE, UV);
//}

void fragment() {
	vec3 rgb = texture(TEXTURE, UV).rgb;

	vec2 xy_offset = mod(FRAGCOORD.xy, vec2(4.0, 4.0));
	int x = int(xy_offset.x);
	int y = int(xy_offset.y);
	
	float threshold = idx_mat4_2d(y, x);
	rgb += vec3(threshold * r);
	if (rgb.r < (1.0 / 3.0)) {
		COLOR.rgb = vec3(0.0);
	} else if (rgb.r < (2.0 / 3.0)) {
		COLOR.rgb = vec3(0.5);
	} else {
		COLOR.rgb = vec3(1.0);
	}
//	COLOR = texture(TEXTURE, UV);
}
