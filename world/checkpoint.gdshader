shader_type spatial;
render_mode cull_disabled;

varying vec3 vert;

uniform float threshold : hint_range(-1.0, 1.0, 0.1);
uniform float error_correction : hint_range(0.0, 1.0, 0.1);
uniform vec4 color : source_color;

void vertex() {
	vert = VERTEX;
}

void fragment() {
	ALBEDO = color.rgb;
}