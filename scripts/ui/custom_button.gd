extends NinePatchRect
class_name CustomButton

signal pressed

@export var pressed_texture: Texture2D
var _normal_texture: Texture2D

func _ready() -> void:
	_normal_texture = texture
	# NinePatchRect는 기본적으로 마우스 이벤트를 무시하므로 STOP으로 설정
	mouse_filter = MouseFilter.MOUSE_FILTER_STOP

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if pressed_texture:
				for ch: Control in get_children():
					ch.position.y += 3
				texture = pressed_texture
		else:
			for ch: Control in get_children():
				ch.position.y -= 3
			texture = _normal_texture
			# 버튼 영역 내부에서 마우스를 뗐을 때만 pressed 시그널 발생
			if get_global_rect().has_point(get_global_mouse_position()):
				pressed.emit()
