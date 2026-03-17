shader_type spatial;
render_mode unshaded;

uniform vec3 floor_color: source_color;
uniform vec3 dot_color: source_color;
uniform float density = 25.0;
uniform float circle_size: hint_range(0.0,1.0,0.001) = 0.005;

float circle(in vec2 _st, in float _radius){
    vec2 dist = _st-vec2(0.5);
	return 1.-smoothstep(_radius-(_radius*0.01),
                         _radius+(_radius*0.01),
                         dot(dist,dist)*4.0);
}

void fragment() {
	//ALBEDO = vec3(UV.y,0.0,0.0)
	vec2 shifted_uv = fract(UV * density);
	//float r = step(0.2, length( max( abs(shifted_uv)-0.3,0.0)));
	float on_off = vec3( circle(shifted_uv,circle_size) ).r;
	ALBEDO = ((1.0-on_off) * floor_color) + (on_off * dot_color);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
