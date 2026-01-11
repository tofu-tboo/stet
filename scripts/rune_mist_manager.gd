extends CanvasLayer
class_name RuneMistManager

@export var shrink_speed: float = 0.03 # 안개가 조여오는 속도
@export var max_radius: float = 0.8 # 화면 모서리 거리 (UV 기준)

var _radii: Array[float] = []

# 씬 구성 시 ColorRect 노드가 자식으로 있어야 함
@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	# 그룹 등록 (Beam에서 호출하기 위함)
	add_to_group("MistManager")
	
	# 반지름 배열 초기화 (모두 최대 거리로)
	_radii.resize(64)
	_radii.fill(max_radius)

func _process(delta: float) -> void:
	# 1. 안개 조여오기 (모든 방향 반지름 감소)
	for i in range(64):
		_radii[i] = max(_radii[i] - shrink_speed * delta, 0.0)
	
	# 2. 쉐이더 업데이트
	if color_rect and color_rect.material is ShaderMaterial:
		(color_rect.material as ShaderMaterial).set_shader_parameter("radii", _radii)

# Beam에서 호출: 특정 방향의 안개를 밀어냄
func push_mist(origin: Vector2, direction: Vector2, power: float) -> void:
	# 화면 중심과 빔의 시작점(origin)을 고려하여 각도 계산
	var viewport_trans = get_viewport().get_canvas_transform()
	var screen_center = get_viewport().get_visible_rect().size / 2.0
	
	# 빔이 뻗어나가는 방향의 먼 지점을 화면 좌표로 변환하여 각도 계산
	var far_point_screen = viewport_trans * (origin + direction * 2000.0)
	var angle = (far_point_screen - screen_center).angle()
	
	var angle_norm = (angle / TAU) + 0.5 # 0 ~ 1
	var center_idx = int(angle_norm * 64.0) % 64
	
	# 중심 인덱스와 주변 인덱스를 함께 밀어내어 구멍을 냄
	var push_amt = power
	_apply_push(center_idx, push_amt)
	
	# 주변부도 부드럽게 밀림
	_apply_push(center_idx - 1, push_amt * 0.8)
	_apply_push(center_idx + 1, push_amt * 0.8)
	_apply_push(center_idx - 2, push_amt * 0.5)
	_apply_push(center_idx + 2, push_amt * 0.5)
	_apply_push(center_idx - 3, push_amt * 0.3)
	_apply_push(center_idx + 3, push_amt * 0.3)

func _apply_push(idx: int, amount: float) -> void:
	# 인덱스 순환 처리 (0 <-> 63)
	var i = (idx + 64) % 64
	_radii[i] = min(_radii[i] + amount, max_radius)
