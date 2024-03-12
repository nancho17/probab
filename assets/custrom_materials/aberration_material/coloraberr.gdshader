shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx,unshaded,shadows_disabled,ambient_light_disabled;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform vec2 r_displacement = vec2(3.0, 0.0);
uniform vec2 g_displacement = vec2(0.0, 0.0);
uniform vec2 b_displacement = vec2(-3.0, 0.0);

void fragment() {
	float change_sec = 1.25;
	float r = texture(screen_texture, SCREEN_UV + vec2(VIEW.x*r_displacement), 0.0).r;
	float g = texture(screen_texture, SCREEN_UV + vec2(VIEW.y*g_displacement), 0.0).g;
	float b = texture(screen_texture, SCREEN_UV + vec2(VIEW.z*b_displacement), 0.0).b;
	vec4 aberrt = vec4(r, g, b, 1.0);
	ALBEDO = aberrt.rgb;
}