shader_type canvas_item;

const int MODE_TEXTURE_ONLY         = 0;
const int MODE_OUTLINE_ONLY         = 1;
const int MODE_OUTLINE_WITH_TEXTURE = 2;
const int MODE_STRIPE_ONLY          = 3;
const int MODE_STRIPE_WITH_TEXTURE  = 4;

uniform int draw_mode : hint_range(0, 4, 1) = 0;

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform int outline_thickness : hint_range(1, 8, 1) = 1;

uniform float rotation_speed : hint_range(-4.0, 4.0) = 0.3;
uniform float stripes : hint_range(1.0, 32.0, 1.0) = 16.0;
uniform float stripe_width : hint_range(0.0, 1.0) = 0.5;

const float ALPHA_THRES = 0.01;

void fragment() {
    vec4 base = texture(TEXTURE, UV);
    vec2 px = TEXTURE_PIXEL_SIZE;

    /* ---- outline 판정 ---- */
    bool empty = base.a <= ALPHA_THRES;
    bool within = false;

    // 컴파일 안전용 고정 루프 (최대 8)
    for (int dy = -8; dy <= 8; dy++) {
        for (int dx = -8; dx <= 8; dx++) {
            if (abs(dx) > outline_thickness || abs(dy) > outline_thickness) {
                continue;
            }
            if (dx == 0 && dy == 0) {
                continue;
            }

            float a = texture(TEXTURE, UV + vec2(float(dx), float(dy)) * px).a;
            if (a > ALPHA_THRES) {
                within = true;
            }
        }
    }

    bool outline = empty && within;

    /* ---- stripe 계산 (outline 영역용 마스크) ---- */
    float fill = 1.0;
    if (draw_mode == MODE_STRIPE_ONLY || draw_mode == MODE_STRIPE_WITH_TEXTURE) {
        float rotation = TIME * rotation_speed;

        // 텍스처 픽셀 기준 좌표 (중심 기준)
        vec2 p = vec2(
            floor((UV.x - 0.5) / px.x),
            floor((UV.y - 0.5) / px.y)
        );

        float angle = atan(
            p.x * cos(rotation) + p.y * sin(rotation),
            p.y * cos(rotation) - p.x * sin(rotation)
        );

        float t = mod((angle - PI) / -TAU, 1.0 / stripes);
        fill = t < stripe_width / stripes ? 1.0 : 0.0;
    }


	vec4 res_col = vec4(0.0);

	if (draw_mode == MODE_TEXTURE_ONLY) {
	    res_col = base;
	}
	else if (draw_mode == MODE_OUTLINE_ONLY) {
	    res_col = outline ? outline_color : vec4(0.0);
	}
	else if (draw_mode == MODE_OUTLINE_WITH_TEXTURE) {
	    res_col = outline ? outline_color : base;
	}
	else if (draw_mode == MODE_STRIPE_ONLY) {
	    res_col = (outline && fill > 0.0) ? outline_color : vec4(0.0);
	}
	else if (draw_mode == MODE_STRIPE_WITH_TEXTURE) {
	    res_col = (outline && fill > 0.0) ? outline_color : base;
	}

	COLOR = res_col;

}
