shader_type canvas_item;

uniform vec4 color_inner : source_color = vec4(1.0, 0.9, 0.6, 1.0); // 안쪽/밝은 색 (예: 연한 노랑)
uniform vec4 color_outer : source_color = vec4(1.0, 0.2, 0.2, 1.0); // 바깥쪽/진한 색 (예: 빨강)
uniform float speed = 20.0;
uniform float frequency = 10.0;
uniform float amplitude = 0.1;
uniform float beam_width_max = 0.3; // 빔의 최대 두께 (0.5를 넘으면 잘릴 수 있음)
uniform float ripple_speed = 30.0; // 내부 파동 속도

void fragment() {
	// 1. 헤엄치는 움직임 (Sine wave)
	float wave = sin(UV.x * frequency - TIME * speed) +
				 sin(UV.x * frequency * 0.8 + TIME * speed * 0.5);

	// 2. 빔의 중심축을 파동에 따라 이동 (모양 자체가 움직임)
	float current_center_y = 0.5 + wave * amplitude;

	// 3. 현재 픽셀이 중심축에서 얼마나 떨어져 있는지 계산
	float dist = abs(UV.y - current_center_y);

	// 4-1. 진행하는 파동 계산 (색상 및 두께 변형용)
	float ripple = sin(UV.x * 30.0 - TIME * ripple_speed);

	// 4. 부채꼴(삼각형) 모양 정의: 시작점(UV.x=0)에서는 폭이 0, 끝점에서는 beam_width_max
	// 파동에 따라 두께가 약간 변하도록 하여 물결 느낌 추가
	float current_width = UV.x * beam_width_max + ripple * 0.03 * UV.x;

	// 5. 끝부분 둥글게 처리 (Round Cap)
	// 중심에서 멀어질수록 빔의 유효 길이를 짧게 인식하게 하여 둥근 모양을 만듦
	float normalized_dist = dist / (current_width + 0.0001); // 0 나누기 방지
	float end_curve = 1.0 - pow(normalized_dist, 2.0) * 0.05; // 0.1: 둥근 정도 (값이 클수록 더 둥글게 파임)

	// 6. 단색 및 하드 엣지 (안티앨리어싱 제거, step 함수 사용)
	// 기존 폭 제한(dist < current_width) AND 길이 제한(UV.x < end_curve)
	float alpha = step(dist, current_width) * step(UV.x, end_curve);

	// 7. 내부 색상 밴드 (단색 스타일 유지하면서 파동 표현)
	// ripple 값이 0보다 크면 안쪽 색, 아니면 바깥쪽 색 (하드 엣지 교차)
	float band = step(0.0, ripple);
	COLOR = mix(color_outer, color_inner, band);
	
	COLOR.a *= alpha;
}