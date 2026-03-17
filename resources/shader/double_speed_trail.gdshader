shader_type spatial;
render_mode unshaded;


void fragment() {
	ALBEDO = vec3(UV.x,UV.y,0.0);
	ALPHA = UV.y;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
