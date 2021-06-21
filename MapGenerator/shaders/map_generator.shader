shader_type canvas_item;

uniform float fill : hint_range(0.0, 1.0) = 0.5;
uniform int scale : hint_range(1, 100) = 100;
uniform int border : hint_range(0, 10) = 1;
uniform float seed : hint_range(0.0, 100.0) = 0.0;

uniform int smoothing : hint_range(1, 3) = 1;

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

float get_recursive_smoothing(vec2 id) {
	// Ceil n
	// int n = min(4, m); // size of the stack for n = 4 -> 820 (1024 for power fo 2)
	
	// Initialise stacks
	bool call_stack[256];
	int n_stack[256];
	vec2 id_stack[256];
	float result_stack[256];
	for (int i = 0 ; i <= 256 ; i ++) {
		call_stack[i] = false;
		n_stack[i] = 0;
		id_stack[i] = vec2(0.0);
		result_stack[i] = 0.0;
	}
	
	int index = 0;
	int last_index;
	
	
	
	int resume_index_stack[256];
	
	// Initialise first call
	call_stack[0] = true;
	n_stack[0] = smoothing;
	id_stack[0] = id;
	last_index = 0;
	
	// Call stack
	while (index < 256 && call_stack[index]) {
		int local_n = n_stack[index];
		vec2 local_id = id_stack[index];
		
		if (local_n == 1) {
			result_stack[index] = get_black_value(local_id);
		}
		else {
			resume_index_stack[index] = last_index + 1; // from where to start to find resume index
			
			for (int x = -1 ; x <= 1 ; x++) {
				for (int y = -1 ; y <= 1 ; y++) {
					vec2 offset = vec2(float(x), float(y));
					
					call_stack[last_index + 1] = true;
					n_stack[last_index + 1] = local_n - 1;
					id_stack[last_index + 1] = local_id - offset;
					
					last_index++;
				}
			}
		}
		index++;
	}
	
	// Resume stack
	while (index > 0) {
		index--;
		
		int local_n = n_stack[index];
		if (local_n > 1) {
			vec2 local_id = id_stack[index];
			int resume_index = resume_index_stack[index];
			
			float local_result = 0.0;
			for (int i = 0 ; i <= 9 ; i++) {
				local_result += result_stack[resume_index + i];
			}
			result_stack[index] = get_border(local_id, local_result / 9.0);
		}
	}
	
	return get_border(id, result_stack[0]);
}

//int factorial(int n) {
//	// Initialise stacks
//	bool call_stack[16]; // false by default
//	bool resume_stack[16]; // false by default
//
//	int n_stack[16];
//
//	// Initialise first call
//	call_stack[0] = true;
//	n_stack[0] = n;
//
//	int index = 0;
//
//	int result;
//
//	// Call stack
//	while (index < 16 && call_stack[index]) {
//		n = n_stack[index];
//		if (n == 1) {
//			result = 1;
//		}
//		else {
//			resume_stack[index] = true;
//
//			call_stack[index + 1] = true;
//			n_stack[index + 1] = n - 1;
//		}
//		index++;
//	}
//	// Resume stack
//	index = 0;
//	while (index < 16 && resume_stack[index]) {
//		n = n_stack[index];
//		result *= n;
//		index++;
//	}
//
//	return result;
//}

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
	
	COLOR = vec4(vec3(get_recursive_smoothing(id)), 1.0);
}