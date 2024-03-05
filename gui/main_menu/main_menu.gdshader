shader_type canvas_item;

float random (vec2 st) {
	return fract(sin(dot(st.xy,vec2(12.9898,78.233)))*43758.5453123);
}

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 0.667, 0.334, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {

	float change_sec = 0.1;
	float x = floor(UV.x);
	float y = floor(UV.y);
	//vec3 hue = vec3( random(vec2(x * y + x + y + floor(TIME * change_sec ))), 1.0, 1.0);
	vec3 hue = vec3( ((x * y + x + y + (TIME * change_sec ))), 1.0, 1.0);
	hue = hsv2rgb(hue);
    COLOR.rgb = hue;
}