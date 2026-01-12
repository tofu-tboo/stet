extends Marker2D

enum CursorType {
	ARROW,
	HAND,
	IBEAM
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	set_cursor(CursorType.ARROW)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(_delta) -> void:
	var hovered = get_viewport().gui_get_hovered_control()
	global_position = get_viewport().get_mouse_position()
	
	if hovered:
		if hovered.mouse_default_cursor_shape == Control.CURSOR_POINTING_HAND:
			set_cursor(CursorType.HAND)
		elif hovered.mouse_default_cursor_shape == Control.CURSOR_IBEAM:
			set_cursor(CursorType.IBEAM)
		else:
			set_cursor(CursorType.ARROW)
	else:
		set_cursor(CursorType.ARROW)

func set_cursor(type: CursorType) -> void:
	$Arrow.hide()
	$Hand.hide()
	$IBeam.hide()
	match type:
		CursorType.ARROW:
			$Arrow.show()
		CursorType.HAND:
			$Hand.show()
		CursorType.IBEAM:
			$IBeam.show()
