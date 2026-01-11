@abstract
extends Sprite2D
class_name AnimPart

var _cur_pose: Player.POSE:
	set(v):
		if _cur_pose == v:
			return
		_cur_pose = v

		_stated(_cur_pose)
var _pose_q: PackedByteArray
var _priority: Dictionary[Player.POSE, int]: # priority needed to be positive
	set(v):
		var _max: int = -1
		var checker: Dictionary[int, bool] = {}
		for val: int in v.values():
			if not checker.has(val):
				checker[val] = true
			else:
				get_tree().free()
			
			if val > _max:
				_max = val
		_priority = v
		_pose_q = PackedByteArray()
		_pose_q.resize(_max + 1)
var _tween: Dictionary[String, Tween] = { "pose": null, "rot": null }

var _init_state: Dictionary[String, Variant]

func _enter_tree() -> void:
	_init_state["offset"] = offset
	_init_state["pos"] = position
	_init_state["rot"] = rotation

func posed_in(pose: Player.POSE) -> void:
	if pose in _priority:
		_pose_q[_priority[pose]] = 1
		if _priority[_cur_pose] <= _priority[pose] and _cur_pose != pose:
			_cur_pose = pose
func posed_out(pose: Player.POSE) -> void:
	if pose in _priority:
		_pose_q[_priority[pose]] = 0
		var last: int = _pose_q.rfind(1)
		if last != -1:
			_cur_pose = _priority.find_key(last)

@abstract
func _stated(pose: Player.POSE)

@abstract
func turn_around(dir: int)

func _reset_tween() -> void:
	for key: String in _tween:
		if _tween[key] != null:
			_tween[key].kill()

func _anim_init(key: String = "all") -> void:
	match key:
		"pos":
			_tween["pos"] = create_tween()
			_tween["pos"].tween_property(self, "position", _init_state["pos"], 0.1)
		"rot":
			_tween["rot"] = create_tween()
			_tween["rot"].tween_property(self, "rotation", _init_state["rot"], 0.1)
		"all":
			_tween["pos"] = create_tween()
			_tween["pos"].tween_property(self, "position", _init_state["pos"], 0.1)
			_tween["rot"] = create_tween()
			_tween["rot"].tween_property(self, "rotation", _init_state["rot"], 0.1)
