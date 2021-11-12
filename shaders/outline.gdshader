shader_type canvas_item;

uniform vec4 outline_color : hint_color;
uniform float outline_width : hint_range(0.0,10.0) = 2.0;
uniform bool rainbow = false;
uniform float rainbow_speed : hint_range(0.0,100.0) = 10.0;

vec3 hsv2rgb(vec3 c) {
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
	COLOR = texture(TEXTURE,UV);
	if(COLOR.a == 0.0) {
		float a[8];
		a[0] = texture(TEXTURE,UV+vec2(1.0,0.0)*outline_width/100.0).a;
		a[1] = texture(TEXTURE,UV+vec2(0.0,1.0)*outline_width/100.0).a;
		a[2] = texture(TEXTURE,UV+vec2(-1.0,0.0)*outline_width/100.0).a;
		a[3] = texture(TEXTURE,UV+vec2(0.0,-1.0)*outline_width/100.0).a;
		a[4] = texture(TEXTURE,UV+vec2(1.0,-1.0)*outline_width/100.0).a;
		a[5] = texture(TEXTURE,UV+vec2(-1.0,-1.0)*outline_width/100.0).a;
		a[6] = texture(TEXTURE,UV+vec2(1.0,1.0)*outline_width/100.0).a;
		a[7] = texture(TEXTURE,UV+vec2(-1.0,1.0)*outline_width/100.0).a;
		if(rainbow) COLOR.rgb = hsv2rgb(vec3(mod(TIME*rainbow_speed/20.0,1.0),1.0,1.0));
		else COLOR.rgb = outline_color.rgb;
		float m = 0.0;
		for(int i = 0; i < 8; i++) {
			if(a[i] > m) m = a[i]
		}
		COLOR.a = m;
	}
}