shader_type canvas_item;

uniform float fill : hint_range(0.0, 1.0) = 0.5;
uniform int scale : hint_range(1, 100) = 1;
uniform int border : hint_range(0, 10) = 1;
uniform float seed : hint_range(0.0, 100.0) = 0.0;

float random_float(vec2 base) {
	return fract(sin(dot(base.xy, vec2(12.9898 - 74.9294 * seed, 78.233 - 34.15 * seed))) * (43758.5453 + 123.123 * seed));
}

float get_border(vec2 id, float value) {
	float final_fill = fill;
	
	if (int(id.x) <= border - 1 || int(id.y) <= border - 1 || int(id.x) >= scale - border || int(id.y) >= scale - border) {
		final_fill = 1.0;
	}
	value = step(final_fill, value);
	
	return value;
}

float get_black_value(vec2 id) {
	
	
	float black_value = random_float(id);
	
	
	return get_border(id, black_value);
}

float get_recursive_smoothing(int n, vec2 id) {
	if (n <= 1) {
		return get_black_value(id);
	}
	
	float smooth_value = 0.0;
	for (int x = -1 ; x <= 1 ; x++) {
		for (int y = -1 ; y <= 1 ; y++) {
			vec2 offset = vec2(float(x), float(y));
			smooth_value += get_recursive_smoothing(n - 1, id - offset) / 9.0;
		}
	}
	
	return smooth_value;
}

void fragment() {
//	Random Map
	vec2 uv_scaled = UV * float(scale);
	vec2 gv = fract(uv_scaled);
	vec2 id = floor(uv_scaled);
	
	float black_value = 0.0;
	
//	Smooth Map
	for (int x = -1 ; x <= 1 ; x++) {
		for (int y = -1 ; y <= 1 ; y++) {
			vec2 offset = vec2(float(x), float(y));
			black_value += get_black_value(id - offset) / 9.0;
		}
	}
	black_value = get_border(id, black_value);
	
	COLOR = vec4(vec3(black_value), 1.0);
}