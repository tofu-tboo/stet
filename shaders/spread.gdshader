shader_type canvas_item;

uniform float radius : hint_range(0.0, 1.5) = 0.0;
uniform vec4 mist_color : source_color = vec4(0.1, 0.0, 0.1, 0.95);
uniform sampler2D noise_tex : repeat_enable;
uniform float edge_softness = 0.1;
uniform float noise_scale = 0.1;

void fragment() {
	vec2 center = vec2(0.5);
	float dist = distance(UV, center);
	
	// 노이즈 샘플링 (시간에 따라 흐르도록)
	float noise = texture(noise_tex, UV + vec2(TIME * 0.1)).r;
	
	// 노이즈를 반지름에 적용하여 우글거리는 경계면 생성
	float current_r = radius + (noise - 0.5) * noise_scale;
	
	// 중심에서 current_r 까지 안개를 그림
	// dist가 current_r보다 작으면 1.0 (안개), 크면 0.0 (투명)
	float alpha = 1.0 - smoothstep(current_r - edge_softness, current_r, dist);
	
	COLOR = mist_color;
	COLOR.a *= alpha;
}
