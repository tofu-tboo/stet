shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture, filter_nearest, repeat_disable;

uniform vec4 color1 : source_color = vec4(0.24314, 0.15294, 0.13725, 1); // dark palette
uniform vec4 color2 : source_color = vec4(0.96078, 0.96078, 0.86275, 1); // light palette

// 이 값으로 분류 민감도 조절
uniform float threshold = 0.5;

void fragment() {
    vec4 src = texture(screen_tex, SCREEN_UV);

    // 인간 시각에 맞춘 밝기 계산
    float lum = dot(src.rgb, vec3(0.299, 0.587, 0.114));

    // 밝으면 흰 계열, 어두우면 검정 계열
    bool is_light = lum > threshold;

    vec4 outc = is_light ? color2 : color1;
    outc.a = 1.0;

    COLOR = outc;
}
