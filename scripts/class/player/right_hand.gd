extends AnimPart
class_name RightHand

var _dir: int = 1

func _ready() -> void:
	_priority = { Player.POSE.IDLE: 0, Player.POSE.WALK: 1, Player.POSE.JUMP: 2, Player.POSE.ATTACK: 3 }
	set_process(false)

func _stated(pose: Player.POSE) -> void:
	_reset_tween()
	set_process(false)
	match pose:
		Player.POSE.IDLE:
			_anim_init()
		Player.POSE.WALK:
			_anim_init("rot")
			_tween["pos"] = create_tween()
			_tween["pos"].set_loops()
			_tween["pos"].tween_property(self, "position", _init_state["pos"], 0.1)
			_tween["pos"].chain().tween_property(self, "position", _init_state["pos"] + Vector2(2, -2), 0.1)
			_tween["pos"].chain().tween_property(self, "position", _init_state["pos"], 0.1)
			_tween["pos"].chain().tween_property(self, "position", _init_state["pos"] + Vector2(-2, -2), 0.1)
		Player.POSE.JUMP:
			_tween["pos"] = create_tween()
			_tween["pos"].tween_property(self, "position", _init_state["pos"] + Vector2(-6, -15), 0.2)

			_tween["rot"] = create_tween()
			_tween["rot"].tween_property(self, "rotation", _init_state["rot"] + deg_to_rad(-40), 0.2)
		Player.POSE.ATTACK:
			_anim_init("pos")
			set_process(true)

func _process(delta: float) -> void:
	var mouse_pos := get_global_mouse_position()
	var dir_to_mouse := mouse_pos - global_position
	var rotation_target := dir_to_mouse.angle()
	
	global_rotation = lerp_angle(global_rotation, rotation_target + PI / 4 - (PI / 2 if _dir == -1 else 0.0), 15.0 * delta)
	
	var parent_node = get_parent()
	if not parent_node is Node2D:
		return
		
	var local_mouse_pos = parent_node.to_local(mouse_pos)
	
	var vec: Vector2 = local_mouse_pos - _init_state["pos"]
	
	if vec.length() > 20.0:
		vec = vec.normalized() * 20.0
	
	var angle := vec.angle()
	var center_angle := deg_to_rad(-90.0)
	var limit := deg_to_rad(60.0) # +/- 60도 -> 120도 범위 (-150 ~ -30)
	
	var diff := angle_difference(center_angle, angle)
	var clamped_diff := clampf(diff, -limit, limit)
	var final_angle := center_angle + clamped_diff
	
	# 각도가 제한된 벡터로 재구성 (길이는 유지)
	vec = Vector2.from_angle(final_angle) * vec.length()
	
	# 이동 적용
	var target_pos: Vector2 = _init_state["pos"] + vec
	position = position.lerp(target_pos, 15.0 * delta)

func turn_around(dir: int) -> void:
	_dir = dir
