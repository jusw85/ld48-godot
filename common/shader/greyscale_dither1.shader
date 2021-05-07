// https://ldjam.com/events/ludum-dare/48/autumn-hike/autumn-hike-dithering-explained
// https://gist.github.com/kolen/d52d173f484a68c3c0e723b8719618f7
// https://medium.com/the-bkpt/dithered-shading-tutorial-29f57d06ac39
// https://en.wikipedia.org/wiki/Ordered_dithering
// https://github.com/SixLabors/ImageSharp/blob/master/src/ImageSharp/Processing/Processors/Dithering/DHALF.TXT
// https://bisqwit.iki.fi/story/howto/dither/jy/
// https://github.com/allen-garvey/dithermark/
shader_type canvas_item;
render_mode unshaded;

const mat4 m = mat4(
	vec4(1, 9, 3, 11) / 17.0,
	vec4(13, 5, 15, 7) / 17.0,
	vec4(4, 12, 2, 10) / 17.0,
	vec4(16, 8, 14, 6) / 17.0
);

// https://github.com/godotengine/godot-proposals/issues/2175
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

void fragment() {
	vec3 rgb = texture(TEXTURE, UV).rgb;

	vec2 xy_offset = mod(FRAGCOORD.xy, vec2(4.0, 4.0));
	int x = int(xy_offset.x);
	int y = int(xy_offset.y);
	float bayer_val = idx_mat4_2d(y, x);
	
	COLOR.rgb = step(vec3(bayer_val), rgb);
//	COLOR = texture(TEXTURE, UV);
}
