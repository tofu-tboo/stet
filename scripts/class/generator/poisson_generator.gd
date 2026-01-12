class_name PoissonGenerator extends Node2D

@export var screen_padding: float = 40.0 # gap b/w screen & lowest disk
@export var min_gap: float = 0.0:
	set(v):
		min_gap = v
		_set_max_cnt()
@export var max_gap: float:
	set(v):
		if v < min_gap:
			return
		max_gap = v
		_set_gen_region_y()
#
var max_cnt: int: # 지속적인 소환으로 느껴질 수 있는 개수여야 함.
	set(v):
		if v <= 0:
			return
		max_cnt = v
		_set_gen_region_y()
@export var _cnt_per_tick: int = 10: # 이번 틱의 앵커가 두 틱 전의 앵커와 충돌하지 않을 정도의 개수를 소환해야 함. 단, 적절히 restrait 되는 개수로 설정해야 함.
	set(v):
		if v <= 0 or v >= max_cnt:
			return
		_cnt_per_tick = v
@export var _ratio: Array[float] = []
#
const _eff_deg: float = PI / 6
@export var _platform_scenes: Array[PackedScene] = []
#
var gen_region_y: float
#
var mutant_rate: float = 0.1 # 난이도 param
#
var _gen_prob: Array[float] = []
var _seeds: Array[Dock] = []
@export var gen_dir: Vector2 = Vector2.UP:
	set(v):
		gen_dir = v

@export var gen_intv: float = 1.0

func _ready() -> void:
	SingletonHook.sure_only_one_load(self)

	var sum: float = 0
	for r in _ratio:
		sum += r
	for i in _ratio.size(): # 누적 확률
		_ratio[i] /= sum
		_gen_prob.append(_ratio[i] + (_gen_prob[i - 1] if i > 0 else 0.0))

	_set_max_cnt()
	_set_gen_region_y()

	_seeds.clear()

	$Tick.wait_time = gen_intv
	#$Tick.stop()

func start_generation() -> void:
	$Tick.start()

func generate(hard_seeds: Array[Dock] = [], restrains: Array[Dock] = [], explode: bool = false, constraint: Rect2 = Rect2((Utility.world_x - Utility.world_y) * 0.5, Utility.world_y, Utility.world_y, gen_region_y)) -> void:
	#var test_msec = Time.get_ticks_msec()
	if Counter.how_many(&"Obstacle") >= max_cnt:
		return
		
	if len(hard_seeds) > 0:
		_seeds = hard_seeds
	
	if _seeds.is_empty():
		_seeds.append(Dock.new(Vector2((Utility.world_x - Utility.world_y) * 0.5 + randf() * Utility.world_y, Utility.world_y + screen_padding), 0, null))
	else:
		_update_seeds()
	var active_list: Array[Dock] = [_seeds[0]] # 생성 기준점이 될 수 있는 앵커 집합, 처음에는 가장 상위의 앵커만
	var restrain_list: Array[Dock] = _seeds.duplicate() # 거리 조건 검사를 위한 앵커 집합
	var highest_dock: Dock = _get_lowest_dock()
	
	restrain_list.append_array(restrains)
	active_list.append_array(restrains)
	
	_seeds.clear()
	for _i in _cnt_per_tick if not explode else max_cnt: # 한 틱에 생성 개수 고정
		var new_obs: Obstacle = _gen_obstacle()
		var new_size: float = new_obs.get_space_radius()
		if new_obs == null:
			continue
		
		while true: # 위치 탐색
			var norm: Dock = active_list.pick_random()
			var dir: Vector2 = _get_dir()
			var candidate_pos: Vector2 = norm.disk.pos + dir * (norm.disk.radius + new_size + randf_range(min_gap, max_gap))
			var is_valid: bool = true
			var candidate_disk: Disk = Disk.new(candidate_pos, new_size) # 거리 비교 위한 디스크 생성
			
			if _constraint_test(candidate_disk, constraint):
				continue # 화면 안쪽 또는 화면 가로 밖이면 다시 시도

			for dock: Dock in restrain_list:
				if Disk.gap(candidate_disk, dock.disk) < min_gap:
					is_valid = false
					continue
			
			if is_valid:
				var new_dock: Dock = Dock.new(candidate_pos, new_size, new_obs)
				active_list.append(new_dock)
				restrain_list.append(new_dock)
				
				if highest_dock.disk.pos.y + highest_dock.disk.radius < new_dock.disk.pos.y + new_dock.disk.radius:
					highest_dock = new_dock
					_seeds.push_front(new_dock) # 결국 가장 위에 있는 앵커가 0 index임.
				else:
					_seeds.push_back(new_dock)

				# floating 활성화
				# candidate_pos is already in scene coords (Dock uses platform.position), so don't double-offset.
				new_obs.position = candidate_pos
				new_obs.show()
				
				break
	
	if _seeds.size() > _cnt_per_tick:
		_seeds.slice(0, _cnt_per_tick)
	
	#prints("msec", Time.get_ticks_msec() - test_msec)

func _rand_type() -> int:
	var r: float = randf()
	for i in _gen_prob.size():
		if r < _gen_prob[i]:
			return i
	return _gen_prob.size() - 1

func _gen_obstacle() -> Obstacle:
	var type: int = _rand_type()
	var obs: Obstacle = _platform_scenes[type].instantiate() as Obstacle
	
	obs.hide()
	get_tree().current_scene.add_child(obs)

	# 씬에 추가만 한 뒤 반환, 위치 확정 이후 활성화
	return obs

func _update_seeds() -> void:
	for dock in _seeds:
		dock.update()

func _get_dir() -> Vector2:
	if randf() < mutant_rate:
		return Vector2.LEFT.rotated(randf_range(PI, PI * 2))
	return Vector2.LEFT.rotated(randf_range(-_eff_deg, 0) + (_eff_deg + PI) * (randi() % 2))

func _constraint_test(disk: Disk, constraint: Rect2) -> bool:
	if constraint.grow(-disk.radius).has_point(disk.pos):
		return false
	return true

func _set_gen_region_y() -> void:
	gen_region_y = max_cnt * max_gap

func _set_max_cnt() -> void:
	max_cnt = _num_circle_packing(Utility.world_area, min_gap, 10) + _cnt_per_tick * 3

func _get_lowest_dock() -> Dock:
	var dir: Vector2 = gen_dir
	if dir == Vector2.ZERO:
		dir = Vector2.UP
	dir = dir.normalized()
	var x: float = 0.0 if dir.x >= 0.0 else float(Utility.world_x)
	var y: float = 0.0 if dir.y >= 0.0 else float(Utility.world_y)
	return Dock.new(Vector2(x, y), 0.0, null)

func _num_circle_packing(region: float, radius: float, extra: float = 0.0) -> int:
	return floor(0.91 * region / (PI * (extra + radius) ** 2))
