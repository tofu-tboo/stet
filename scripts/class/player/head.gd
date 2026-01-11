extends AnimPart
class_name Head

func _ready() -> void:
	_priority = {}

func _stated(pose: Player.POSE) -> void:
	pass

func turn_around(_dir: int) -> void:
	pass

func _process(_delta: float) -> void:
	var to_mouse: Vector2 = get_global_mouse_position() - global_position
	if to_mouse == Vector2.ZERO:
		return

	var side: int = (1 if to_mouse.x >= 0 else -1)

	global_scale.x = side
	global_rotation = to_mouse.angle()
