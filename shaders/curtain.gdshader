shader_type canvas_item;

uniform float cutoff : hint_range(0.0, 1.5) = 0.0;
uniform vec4 curtain_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform sampler2D noise_tex : repeat_enable;
uniform float edge_softness = 0.1;
uniform float noise_scale = 0.1;

void fragment() {
	// 노이즈 샘플링 (시간에 따라 흐르도록)
	float noise = texture(noise_tex, vec2(UV.x, TIME * 0.1)).r;
	
	// 커튼의 끝자락 위치 계산 (노이즈 적용)
	float current_y = cutoff + (noise - 0.5) * noise_scale;
	
	// 위에서부터 current_y까지 채움
	// UV.y가 current_y보다 작으면 1.0 (불투명), 크면 0.0 (투명)
	float alpha = 1.0 - smoothstep(current_y - edge_softness, current_y, UV.y);
	
	COLOR = curtain_color;
	COLOR.a *= alpha;
}
