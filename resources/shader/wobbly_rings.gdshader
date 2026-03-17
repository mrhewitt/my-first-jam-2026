shader_type spatial;
render_mode unshaded;

uniform sampler2D ring_texture  ;
uniform sampler2D noise_1 : repeat_enable;
uniform sampler2D noise_2 : repeat_enable;
uniform vec3 tint: source_color;
uniform float amount: hint_range(0.0,1.0,0.1);


void fragment() {
	float sample_1 = texture(noise_1, UV + TIME*0.1).r - 0.5;
	float sample_2 = texture(noise_2, UV - TIME*0.2).r - 0.5;
	float mixed_noise = sample_1 * sample_2 * 2.0;
	
	vec2 offset =  vec2(0.18, 0.18) * mixed_noise;
	vec4 texel = texture( ring_texture, UV + offset );
	ALBEDO = tint;
	
	sample_1 = texture(noise_1, UV + TIME*0.15).r;
	sample_2 = texture(noise_2, UV - TIME*0.25).r;
	mixed_noise = sample_1 * sample_2;
	ALPHA = texel.r * (1.0 - (mixed_noise * 6.0 * amount));
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
