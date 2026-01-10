extends Sprite2D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	centered = false # 좌상단 기준 (hotspot 직접 맞추기 쉬움)

func _process(_delta) -> void:
	global_position = get_viewport().get_mouse_position()
