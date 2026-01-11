extends Node

func _ready():
	if OS.has_feature("editor") or OS.has_feature("web"):
		return
		
	var base: Vector2i = Vector2i(ProjectSettings.get_setting_with_override(&"display/window/size/viewport_width"), ProjectSettings.get_setting_with_override(&"display/window/size/viewport_height"))
	var screen_size: Vector2i = DisplayServer.screen_get_size()

	var scale_x: int = screen_size.x / base.x
	var scale_y: int = screen_size.y / base.y
	var scale: float = min(scale_x, scale_y)

	# 최소 1배 보장
	scale = max(scale, 1)

	var window_size: Vector2i = base * scale
	DisplayServer.window_set_size(window_size)

	# 중앙 정렬
	var pos: Vector2i = (screen_size - window_size) / 2
	DisplayServer.window_set_position(pos)
