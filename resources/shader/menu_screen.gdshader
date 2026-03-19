shader_type canvas_item;

uniform vec3 floor_color: source_color;
uniform vec3 dot_color: source_color;
uniform float density = 25.0;
uniform float circle_size: hint_range(0.0,1.0,0.001) = 0.005;

// controls direction of scrolling
uniform vec2 offset;

float circle(in vec2 _st, in float _radius){
    vec2 dist = _st-vec2(0.5);
	return 1.-smoothstep(_radius-(_radius*0.01),
                         _radius+(_radius*0.01),
                         dot(dist,dist)*4.0);
}

void fragment() {
	vec2 shifted_uv = fract((UV + offset * TIME) * density);
	float on_off = vec3( circle(shifted_uv,circle_size) ).r;
	COLOR = vec4( ((1.0-on_off) * floor_color) + (on_off * dot_color), 1.0 );
}
