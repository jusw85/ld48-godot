// https://ldjam.com/events/ludum-dare/48/autumn-hike/autumn-hike-dithering-explained
// https://gist.github.com/kolen/d52d173f484a68c3c0e723b8719618f7
// https://medium.com/the-bkpt/dithered-shading-tutorial-29f57d06ac39
// https://en.wikipedia.org/wiki/Ordered_dithering
// https://github.com/SixLabors/ImageSharp/blob/master/src/ImageSharp/Processing/Processors/Dithering/DHALF.TXT
// https://bisqwit.iki.fi/story/howto/dither/jy/
// https://github.com/allen-garvey/dithermark/
shader_type canvas_item;
render_mode unshaded;
// r = 1 / cbrt(num_colours) = 1 / cbrt(2)
uniform float r: hint_range(0, 1) = 0.79370052598;
uniform float threshold: hint_range(0, 1) = 0.5;

const mat4 m = mat4(
	(vec4(0, 8, 2, 10) / 15.0) - 0.5,
	(vec4(12, 4, 14, 6) / 15.0) - 0.5,
	(vec4(3, 11, 1, 9) / 15.0) - 0.5,
	(vec4(15, 7, 13, 5) / 15.0) - 0.5
);

// https://github.com/allen-garvey/dithermark/blob/e6711ee5c4a44413139261c29f947071bbe0fa1e/js_src/shared/bayer-matrix.js
// hatch right
//const mat4 m = mat4(
//	(vec4(15, 7.5, 0, 7.5) / 15.0) - 0.5,
//	(vec4(7.5, 0, 7.5, 15) / 15.0) - 0.5,
//	(vec4(0, 7.5, 15, 7.5) / 15.0) - 0.5,
//	(vec4(7.5, 15, 7.5, 0) / 15.0) - 0.5
//);

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

// https://en.wikipedia.org/wiki/HSL_and_HSV#Lightness
float lightness(vec3 rgb) {
	float lmax = max(max(rgb.r, rgb.g), rgb.b);
	float lmin = min(min(rgb.r, rgb.g), rgb.b);
	return (lmax + lmin) / 2.0;
}

//float lightness(vec3 rgb) {
//	return dot(rgb, vec3(0.2989, 0.5870, 0.1140));
//}

void fragment() {
	vec3 rgb = texture(TEXTURE, UV).rgb;

	vec2 xy_offset = mod(FRAGCOORD.xy, vec2(4.0, 4.0));
	int x = int(xy_offset.x);
	int y = int(xy_offset.y);
	float bayer_val = idx_mat4_2d(y, x);
	float lightness = lightness(rgb);
	
	bool cond = lightness + (r * bayer_val) < threshold;
	if (cond) {
		COLOR.rgb = vec3(0.0);
	} else {
		COLOR.rgb = vec3(1.0);
	}
//	COLOR = texture(TEXTURE, UV);
}
