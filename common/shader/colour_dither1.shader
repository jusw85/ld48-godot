// https://ldjam.com/events/ludum-dare/48/autumn-hike/autumn-hike-dithering-explained
// https://gist.github.com/kolen/d52d173f484a68c3c0e723b8719618f7
// https://medium.com/the-bkpt/dithered-shading-tutorial-29f57d06ac39
// https://en.wikipedia.org/wiki/Ordered_dithering
// https://github.com/SixLabors/ImageSharp/blob/master/src/ImageSharp/Processing/Processors/Dithering/DHALF.TXT
// https://bisqwit.iki.fi/story/howto/dither/jy/
// https://github.com/allen-garvey/dithermark/
shader_type canvas_item;
render_mode unshaded;
// r = 1 / cbrt(num_colours)
uniform float r: hint_range(0, 1) = 0.69336127435;

// no uniform arrays
// https://github.com/godotengine/godot-proposals/issues/931
uniform sampler2D palette;
uniform int texture_width;

const mat4 m = mat4(
	(vec4(0, 8, 2, 10) / 15.0) - 0.5,
	(vec4(12, 4, 14, 6) / 15.0) - 0.5,
	(vec4(3, 11, 1, 9) / 15.0) - 0.5,
	(vec4(15, 7, 13, 5) / 15.0) - 0.5
);

// no matrix indexing
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

float quick_distance(vec3 p1, vec3 p2){
	vec3 dist = p1 - p2;
	return dot(vec3(1.0), dist * dist);
}

void fragment() {
	vec3 rgb = texture(TEXTURE, UV).rgb;

	vec2 xy_offset = mod(FRAGCOORD.xy, vec2(4.0, 4.0));
	int x = int(xy_offset.x);
	int y = int(xy_offset.y);
	float bayer_val = idx_mat4_2d(y, x);
	
//	float computed_r = r;
	float computed_r = pow(float(texture_width), (-1.0 / 3.0));
	rgb = clamp(rgb + vec3(computed_r * bayer_val), 0.0, 1.0);
	vec3 new_rgb = rgb;
	float min_dist = 9999.0;
	
	float interval = 1.0 / float(texture_width);
	float st = interval / 2.0;
	
	for (int i = 0; i < texture_width; i++) {
		vec2 palette_coord = vec2(st + (float(i) * interval), 0.5);
		vec3 palette_col = texture(palette, palette_coord).rgb;
		float dist = quick_distance(rgb, palette_col);
		if (dist < min_dist) {
			min_dist = dist;
			new_rgb = palette_col;
		}
	}
	COLOR.rgb = new_rgb;
//	COLOR = texture(TEXTURE, UV);
}
