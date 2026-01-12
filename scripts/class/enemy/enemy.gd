extends CharacterBody2D
class_name Enemy

@export var max_hp: int = 10
@export var speed: float = 300.0
@export var descend_speed: float = 200.0
@export var attack_interval: float = 1.5 # 플레이어 조준 간격
@export var touch_damage: int = 1

var hp: int
var _timer: Timer
var _direction: Vector2 = Vector2.DOWN
var _is_descending: bool = true
var _is_stunned: bool = false

var dead: bool = false

func _ready() -> void:
	hp = max_hp
	add_to_group("Enemy")
	
	_timer = Timer.new()
	_timer.timeout.connect(_on_timer_timeout)
	add_child(_timer)
	
	# 초기 상태: 랜덤 시간(1~3초) 동안 수직 하강
	_timer.wait_time = randf_range(1.0, 3.0)
	_timer.one_shot = true
	_timer.start()
	
	# 플레이어 충돌 감지 (Area2D 노드의 body_entered 시그널 연결)
	$Area2D.body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	# 기절 상태가 아닐 때만 하강 속도 적용
	var current_speed = descend_speed if _is_descending and not _is_stunned else speed
	velocity = _direction * current_speed
	move_and_slide()

func _on_timer_timeout() -> void:
	# 기절 상태에서는 AI 갱신 안 함
	if _is_stunned: return
	if _is_descending:
		# 하강 단계 종료, 추적 단계로 전환
		_is_descending = false
		_aim_at_player()
		
		# 이후 주기적으로 플레이어 위치 갱신
		_timer.wait_time = attack_interval
		_timer.one_shot = false # 반복 실행
		_timer.start()
		
	else:
		# 주기적으로 플레이어 방향으로 갱신
		_aim_at_player()
		

func _aim_at_player() -> void:
	if _is_stunned:
		return
		
	var players = get_tree().get_nodes_in_group("Player")
	if not players.is_empty():
		var player = players[0]
		# 현재 위치에서 플레이어 위치로 향하는 방향 계산 (정규화하여 방향만 가져옴)
		_direction = (player.global_position - global_position).normalized()
		
		$Roar.play()

# Beam 스크립트에서 호출됨
func hurt(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		die()

func die() -> void:
	dead = true
	# 사망 이펙트나 사운드 추가 가능
	
	var tw: Tween = create_tween()
	tw.tween_property(self, "scale", Vector2.ZERO, 0.4)
	tw.finished.connect(queue_free)
	
	$Die.play()

func _on_body_entered(body: Node2D) -> void:
	if body is Player and not _is_stunned and not dead:
		_is_stunned = true
		body.take_damage(touch_damage)
		
		# AI 타이머를 멈추고 기절 상태에 들어감
		_timer.stop()
		
		# 플레이어 반대 방향으로 밀려남
		_direction = (global_position - body.global_position).normalized()
		
		# 1초 후 기절이 풀리고 다시 플레이어를 조준함
		get_tree().create_timer(1.0).timeout.connect(func():
			if not is_instance_valid(self): return
			_is_stunned = false
			_is_descending = false # 기절 후에는 항상 추적 모드
			_on_timer_timeout() # AI 로직 재시작
		)
