extends CanvasLayer
class_name RuneMistManager

const piece = 128

@export var shrink_speed: float = 0.03 # 안개가 조여오는 속도
@export var max_radius: float = 0.8 # 화면 모서리 거리 (UV 기준)
@export var damage_interval: float = 1.0 # 안개 데미지 간격
@export var damage_amount: int = 1 # 안개 데미지 양

var _radii: Array[float] = []
var _smoothed_radii: Array[float] = []
var _noise: FastNoiseLite
var _damage_timer: Timer
var _player: Node2D

# 씬 구성 시 ColorRect 노드가 자식으로 있어야 함
@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	# 그룹 등록 (Beam에서 호출하기 위함)
	add_to_group("MistManager")
	
	# 반지름 배열 초기화 (모두 최대 거리로)
	_radii.resize(piece)
	_radii.fill(max_radius)
	_smoothed_radii = _radii.duplicate()
	
	# 노이즈 초기화
	_noise = FastNoiseLite.new()
	_noise.seed = randi()
	_noise.frequency = 2.0
	
	# 데미지 타이머 설정
	_damage_timer = Timer.new()
	_damage_timer.wait_time = damage_interval
	_damage_timer.one_shot = false
	_damage_timer.timeout.connect(_on_damage_timer_timeout)
	add_child(_damage_timer)

func _process(delta: float) -> void:
	# 1. 안개 조여오기 (모든 방향 반지름 감소)
	for i in range(piece):
		# 깊게 파인 곳(반지름이 큰 곳)은 더 빠르게 다가옴
		var speed_factor = 1.0 + (_radii[i] * 20.0)
		_radii[i] = max(_radii[i] - shrink_speed * speed_factor * delta, 0.0)
		
		# 시각적 보간 (갑자기 변하지 않고 부드럽게 이동)
		_smoothed_radii[i] = lerp(_smoothed_radii[i], _radii[i], delta * 5.0)
	
	# 2. 쉐이더 업데이트
	if color_rect and color_rect.material is ShaderMaterial:
		# 시각적 노이즈 추가 (우글거리는 효과)
		var visual_radii = _smoothed_radii.duplicate()
		var time = Time.get_ticks_msec() * 0.001
		for i in range(piece):
			var angle = (float(i) / float(piece)) * TAU
			# 원형으로 이어지는 3D 노이즈 샘플링
			var noise_val = _noise.get_noise_3d(cos(angle), sin(angle), time) * 0.03
			visual_radii[i] = clamp(visual_radii[i] + noise_val, 0.0, max_radius)
			
		(color_rect.material as ShaderMaterial).set_shader_parameter("radii", visual_radii)
	
	_check_player_in_mist()

func _check_player_in_mist() -> void:
	if not is_instance_valid(_player):
		var players = get_tree().get_nodes_in_group("Player")
		if not players.is_empty():
			_player = players[0]
		return

	var viewport_trans = get_viewport().get_canvas_transform()
	var visible_rect = get_viewport().get_visible_rect()
	var screen_center = visible_rect.size / 2.0
	var min_dim = min(visible_rect.size.x, visible_rect.size.y)
	
	var player_screen_pos = viewport_trans * _player.global_position
	var diff = player_screen_pos - screen_center
	var dist_px = diff.length()
	var current_r_norm = dist_px / min_dim
	
	var angle = diff.angle()
	var angle_norm = (angle / TAU) + 0.5
	var idx = int(angle_norm * float(piece)) % piece
	
	# 안개(구멍 밖)에 있는지 확인 (현재 반지름보다 멀리 있으면 안개 속)
	if current_r_norm > _radii[idx]:
		if _damage_timer.is_stopped():
			_damage_timer.start()
	else:
		_damage_timer.stop()

func _on_damage_timer_timeout() -> void:
	if is_instance_valid(_player):
		_player.take_damage(damage_amount)

# Beam에서 호출: 빔의 시작점(origin)과 끝점(hit_point)을 받아 안개를 밀어냄
func push_mist(origin: Vector2, hit_point: Vector2, power: float) -> void:
	var viewport_trans = get_viewport().get_canvas_transform()
	var visible_rect = get_viewport().get_visible_rect()
	var screen_center = visible_rect.size / 2.0
	var min_dim = min(visible_rect.size.x, visible_rect.size.y)
	
	var start_screen = viewport_trans * origin
	var end_screen = viewport_trans * hit_point
	
	# 중심 기준 좌표계로 변환
	var p1 = start_screen - screen_center
	var p2 = end_screen - screen_center
	
	# 빔의 길이
	var length = p1.distance_to(p2)
	
	# 이번 프레임에 적용할 힘을 저장할 임시 배열 (중복 적용 방지)
	var forces = []
	forces.resize(piece)
	forces.fill(0.0)
	
	# 1. 선분을 따라가며 힘 계산 (5픽셀 단위 샘플링)
	var steps = int(length / 5.0)
	steps = max(steps, 1)
	
	for i in range(steps + 1):
		var t = float(i) / float(steps)
		var p = p1.lerp(p2, t)
		
		var dist_px = p.length()
		var target_r = dist_px / min_dim
		var angle = p.angle()
		
		var angle_norm = (angle / TAU) + 0.5
		var center_idx = int(angle_norm * float(piece)) % piece
		
		var current_r = _radii[center_idx]
		
		# 해당 지점까지 안개를 걷어내기 위한 힘 계산
		# 빔이 안개보다 안쪽에 있으면(target_r < current_r) 밀어내지 않음
		var push_amt = 0.0
		if target_r > current_r:
			# 즉시 제거가 아닌, power만큼 서서히 밀어내도록 변경
			push_amt = power
		
		# 확산 범위 계산
		var final_r = min(current_r + push_amt, max_radius)
		var safe_r = max(final_r, 0.1)
		var spread_count = int(3.0 * (max_radius / safe_r))
		spread_count = clampi(spread_count, 3, piece / 4)

		# 중심점 힘 저장 (Max로 덮어쓰기)
		forces[center_idx] = max(forces[center_idx], push_amt)
		
		# 주변부 힘 저장
		for k in range(1, spread_count + 1):
			var falloff = 1.0 - (float(k) / float(spread_count + 1))
			var amount = push_amt * falloff
			
			var left = (center_idx - k + piece) % piece
			var right = (center_idx + k) % piece
			
			forces[left] = max(forces[left], amount)
			forces[right] = max(forces[right], amount)
			
	# 2. 끝부분 둥글게 파내기 (Bite Effect)
	var bite_radius_uv = 0.2 # 한 입 크기 (화면 비율, 0.2 = 20%)
	var bite_radius_px = bite_radius_uv * min_dim
	var bite_center = p2 # 화면 중심에서 hit_point까지의 벡터
	var bite_dist_sq = bite_center.length_squared()
	var bite_radius_sq = bite_radius_px * bite_radius_px
	
	# 모든 각도에 대해 원과의 교차점 계산
	for i in range(piece):
		# 인덱스를 각도로 변환 (push_mist의 매핑 방식과 일치: -PI ~ PI)
		var angle_rad = (float(i) / float(piece) - 0.5) * TAU
		var dir = Vector2(cos(angle_rad), sin(angle_rad))
		
		# 원과 직선(Ray)의 교차 판별 (t에 대한 2차 방정식)
		# t^2 - 2(dir . C)t + |C|^2 - R^2 = 0
		var dir_dot_c = dir.dot(bite_center)
		var c_val = bite_dist_sq - bite_radius_sq
		var det = dir_dot_c * dir_dot_c - c_val
		
		if det >= 0.0:
			var t = dir_dot_c + sqrt(det) # 먼 쪽 교차점 선택
			if t > 0.0:
				var target_r = t / min_dim
				var current_r = _radii[i]
				
				if target_r > current_r:
					# 끝부분도 서서히 파이도록 변경
					var push_amt = power
					forces[i] = max(forces[i], push_amt)
	
	# 계산된 힘을 실제 반지름에 일괄 적용
	for i in range(piece):
		if forces[i] > 0.0:
			_apply_push(i, forces[i])

func _apply_push(idx: int, amount: float) -> void:
	# 인덱스 순환 처리 (0 <-> 63)
	var i = (idx + piece) % piece
	_radii[i] = min(_radii[i] + amount, max_radius)
