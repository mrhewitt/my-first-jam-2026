shader_type spatial;
render_mode unshaded;

uniform vec3 color: source_color = vec3(0.9,0.0,0.0);
uniform sampler2D noise1 : repeat_enable;
uniform sampler2D noise2 : repeat_enable;
 
void fragment() {
	float noise1_sample = texture( noise1, UV + TIME*0.1).r;
	float noise2_sample = texture( noise2, UV + TIME*0.2).r;
	float mixed_noise = noise1_sample * noise2_sample;
	
	//vec2 offset = vec2(1,1) * mixed_noise;
	ALBEDO = color * noise1_sample;
	ALPHA = clamp(noise2_sample,0.2,1.0);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
