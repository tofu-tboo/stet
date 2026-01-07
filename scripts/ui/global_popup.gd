extends NinePatchRect
class_name GlobalPopup

signal close_requested(popup: GlobalPopup)

@export var anim_duration: float = 0.6

func _ready() -> void:
	hide()
	var close_btn := get_node_or_null("./Close")
	if close_btn != null and close_btn is BaseButton:
		close_btn.button_down.connect(func() -> void: close_requested.emit(self))

func display(buttons: Array[int] = [], duration: float = anim_duration, center_y: float = NAN) -> void:
	var tween: Tween = create_tween()
	var viewport_size: Vector2 = get_viewport_rect().size
	var target_y: float = (center_y if not is_nan(center_y) else viewport_size.y * 0.5) - size.y * 0.5
	
	show()
	position.y = viewport_size.y * 2
	_set_buttons_visible(buttons)
	_focus_first_visible_button()
	
	tween.tween_property(self, "position:y", target_y, duration)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	await tween.finished

func conceal(duration: float = anim_duration) -> void:
	var tween: Tween = create_tween()
	var viewport_size: Vector2 = get_viewport_rect().size
	
	tween.tween_property(self, "position:y", viewport_size.y * -2, duration)
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_SINE)
	
	await tween.finished
	_reset_buttons()
	hide()

func _set_buttons_visible(buttons: Array[int]) -> void:
	var idx: int = -1
	var show_all: bool = buttons.is_empty()
	for btn in $ButtonContainer.get_children():
		assert(btn is Button or btn is TextureButton)
		idx += 1
		btn.visible = show_all or (idx in buttons)

func _reset_buttons() -> void:
	for btn in $ButtonContainer.get_children():
		if btn is Button or btn is TextureButton:
			btn.show()

func _focus_first_visible_button() -> void:
	for btn in $ButtonContainer.get_children():
		if (btn is Button or btn is TextureButton) and btn.visible:
			btn.grab_focus()
			return
