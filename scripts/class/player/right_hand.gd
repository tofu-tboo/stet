extends AnimPart
class_name RightHand

func _ready() -> void:
	_priority = { Player.POSE.IDLE: 0, Player.POSE.WALK: 1, Player.POSE.JUMP: 2, Player.POSE.ATTACK: 3 }

func _stated(pose: Player.POSE) -> void:
	_reset_tween()
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

func turn_around(dir: int) -> void:
	pass
