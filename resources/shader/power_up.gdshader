shader_type spatial;

uniform vec3 color: source_color;
uniform sampler2D noise1 : repeat_enable;

// x goes around, y goes top to bottom
void fragment() {
	ALBEDO = color;
	ALPHA = UV.y * texture( noise1, UV + TIME*0.1).r;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
