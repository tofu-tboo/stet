shader_type canvas_item;

// 360도를 64개 구간으로 나누어 각 구간의 안개 시작 거리를 저장
uniform float radii[64];
uniform vec4 mist_color : source_color = vec4(0.1, 0.0, 0.1, 0.95);
uniform sampler2D noise_tex : repeat_enable; // 안개 경계면을 울렁거리게 할 노이즈
uniform float edge_softness = 0.15; // 경계면 부드러움 정도

void fragment() {
	vec2 center = vec2(0.5);
	// UV 좌표를 -0.5 ~ 0.5 범위로 조정
	vec2 uv_centered = UV - center;
	float dist = length(uv_centered);
	
	// 현재 픽셀의 각도 계산 (-PI ~ PI)
	float angle = atan(uv_centered.y, uv_centered.x);
	
	// 각도를 0~1 범위로 정규화 및 배열 인덱스로 변환
	float angle_norm = (angle / 6.28318530718) + 0.5;
	float idx_f = angle_norm * 64.0;
	int idx = int(idx_f) % 64;
	int next_idx = (idx + 1) % 64;
	float t = fract(idx_f);
	
	// 인접한 두 구간의 반지름을 보간하여 부드러운 곡선 생성
	float r = mix(radii[idx], radii[next_idx], t);
	
	// 노이즈를 더해 경계면을 불규칙하게 만듦
	// TIME을 사용하여 움직이는 안개 효과
	float noise = texture(noise_tex, UV + vec2(TIME * 0.1)).r;
	r -= noise * 0.05;
	
	// 현재 픽셀 거리가 반지름(r)보다 크면 안개 그림
	// dist가 r보다 작으면(안쪽) 0(투명), 크면(바깥쪽) 1(안개색)
	float alpha = smoothstep(r - edge_softness, r, dist);
	
	COLOR = mist_color;
	COLOR.a *= alpha;
}