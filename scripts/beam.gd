extends Line2D
class_name Beam

@export var resolution: int = 20 # 곡선 해상도
@export var wave_amplitude: float = 100.0 # 파동 너비
@export var wave_speed: float = 2.0 # 파동 속도
@export var max_length: float = 2000.0 # 최대 사거리
@export_flags_2d_physics var collision_mask: int = 1 # 충돌 마스크
@export var growth_speed: float = 4000.0 # 빔 발사 속도 (픽셀/초)
@export var damage_interval: float = 0.1 # 데미지 간격 (초)
@export var damage_amount: int = 1 # 틱당 데미지
@export var mist_push_power: float = 0.5 # 안개 밀어내는 힘

# 외부에서 설정할 타겟 위치 (Global 좌표)
var target_position: Vector2 = Vector2.ZERO

# 현재 빔 길이 (애니메이션용)
var _current_length: float = 0.0

# 빔 꼬리 길이 (애니메이션용)
var _tail_length: float = 0.0

# 빔 발사 상태
var is_casting: bool = false

var _timer: Timer

func set_casting(cast: bool) -> void:
	if is_casting == cast:
		return

	is_casting = cast
	if is_casting:
		visible = true
		
		_timer.wait_time = damage_interval
		_timer.start()
		
		$Sound.play()
		$SoundTimer.start()
		
	else:
		_timer.stop()
		$SoundTimer.stop()

func _ready() -> void:
	set_as_top_level(true)
	
	_timer = Timer.new()
	_timer.timeout.connect(_on_timer_timeout)
	add_child(_timer)

	# RayCast2D 생성 및 설정
	$RayCast2D.enabled = true
	$RayCast2D.collide_with_areas = true # 안개(Area2D) 타격을 위해 활성화
	
	# 플레이어(부모) 충돌 예외 처리
	var ancestor = get_parent()
	while ancestor:
		if ancestor is CollisionObject2D:
			$RayCast2D.add_exception(ancestor)
			break
		ancestor = ancestor.get_parent()

	# 쉐이더용 직사각형 메쉬 설정
	if not width_curve:
		var curve := Curve.new()
		curve.add_point(Vector2(0, 1))
		curve.add_point(Vector2(1, 1))
		width_curve = curve

	if width < 50.0:
		width = 120.0
	
	# 배열 크기 초기화
	var pts := PackedVector2Array()
	pts.resize(resolution + 1)
	points = pts
	
	set_process(visible)


func _process(delta: float) -> void:
	# 위치 동기화: CanvasGroup이 있으면 CanvasGroup을 이동, 아니면 Beam을 이동
	var parent = get_parent()
	if parent is CanvasGroup:
		if parent.get_parent() is Node2D:
			parent.global_position = parent.get_parent().global_position
	elif parent is Node2D:
		global_position = parent.global_position

	# Global 좌표인 target_position을 로컬 좌표로 변환
	var local_mouse := to_local(target_position)
	var direction := local_mouse.normalized()

	if local_mouse.length_squared() < 1.0:
		direction = Vector2.RIGHT
	
	# RayCast 업데이트: 마우스 방향으로 최대 사거리까지 쏨
	$RayCast2D.target_position = direction * max_length
	$RayCast2D.force_raycast_update()
	
	var full_vector := direction * max_length
	if $RayCast2D.is_colliding():
		full_vector = to_local($RayCast2D.get_collision_point())
	
	var dist := full_vector.length()

	if is_casting:
		_current_length = move_toward(_current_length, dist, growth_speed * delta)
		_tail_length = 0.0
	else:
		_tail_length = move_toward(_tail_length, _current_length, growth_speed * delta)
		if is_equal_approx(_tail_length, _current_length):
			visible = false

	var start_pos := direction * _tail_length
	var end_pos := direction * _current_length
	
	# 길이가 너무 짧으면 계산 불가 (최소 길이 보정)
	if start_pos.distance_squared_to(end_pos) < 1.0:
		end_pos = start_pos + direction
		
	# 제어점(Control Point) 계산: P0(start_pos) ~ P2(end_pos) 사이 수직 진동
	var mid := (start_pos + end_pos) * 0.5
	var perp := Vector2(-direction.y, direction.x)
	var time_sec := Time.get_ticks_msec() * 0.001
	var control := mid + perp * wave_amplitude * sin(time_sec * wave_speed)
	
	# 베지에 곡선 점 갱신 (P0 = 0,0 최적화)
	var new_points := points # 기존 배열 복사 (COW 최적화 활용)
	var inv_res := 1.0 / float(resolution)
	
	for i in range(resolution + 1):
		var t := float(i) * inv_res
		var one_minus_t := 1.0 - t
		# B(t) = 2(1-t)t*P1 + t^2*P2
		new_points[i] = (one_minus_t * one_minus_t * start_pos) + (2.0 * one_minus_t * t * control) + (t * t * end_pos)
		
	points = new_points


func _on_visibility_changed() -> void:
	if visible:
		_current_length = 0.0
		_tail_length = 0.0
	set_process(visible)

func _on_timer_timeout() -> void:
	_apply_damage()
	
	# 룬 안개 밀어내기 (Timer Timeout 마다 실행)
	var hit_point: Vector2
	if $RayCast2D.is_colliding():
		hit_point = $RayCast2D.get_collision_point()
	else:
		hit_point = to_global($RayCast2D.target_position)
		
	get_tree().call_group("MistManager", "push_mist", global_position, hit_point, mist_push_power * damage_interval)

func _apply_damage() -> void:
	if not $RayCast2D.is_colliding():
		return
	
	var dist := to_local($RayCast2D.get_collision_point()).length()
	
	# 시각적 길이(_current_length)가 실제 충돌 거리(dist)에 거의 도달했는지 확인 (10px 오차 허용)
	if _current_length < dist - 10.0:
		return
	
	var collider: Object = $RayCast2D.get_collider()
	if collider and collider.has_method("hurt"):
		collider.hurt(damage_amount)


func _on_sound_timer_timeout() -> void:
	$Sound.play()
