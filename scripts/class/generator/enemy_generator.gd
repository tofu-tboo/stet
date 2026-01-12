extends Node2D
class_name EnemyGenerator

@export var enemy_scene: PackedScene
@export var intv: float = 16.0

func _ready() -> void:
	# 하위에 있는 Timer 노드의 timeout 시그널 연결
	$Timer.wait_time = intv
	$Timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout() -> void:
	if not enemy_scene:
		return
		
	var count = randi_range(2, 3) # 2~3마리 랜덤
	for i in range(count):
		var enemy = enemy_scene.instantiate()
		# 생성된 적을 Generator의 형제 노드로 추가 (Generator의 이동/회전에 종속되지 않도록)
		get_parent().add_child(enemy)
		# 좌우 -300 ~ 300 범위 내 랜덤 위치 설정
		enemy.global_position = global_position + Vector2(randf_range(-150.0, 150.0), 0)
