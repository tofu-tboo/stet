extends NinePatchRect
class_name GlobalPopup

func _ready() -> void:
	self.hide()
	if get_node_or_null("./Close") != null:
		$Close.button_down.connect(%Popups._close_popup_by_ref.bind(self))

func display(buttons: Array[int], duration: float = 0.6) -> void:
	var popup_tween: Tween = create_tween()
	
	self.show()
	position.y = GlobalUI.screen_y * 2
	show_buttons(buttons)
	
	popup_tween.tween_property(self, "position:y", %CenterMarker.position.y - size.y * 0.5, duration)
	popup_tween.set_ease(Tween.EASE_OUT)
	popup_tween.set_trans(Tween.TRANS_SINE)
	
	await popup_tween.finished


func conceal(duration: float = 0.6) -> void:
	var popup_tween: Tween = create_tween()
	
	popup_tween.tween_property(self, "position:y", GlobalUI.screen_y * -2, duration)
	popup_tween.set_ease(Tween.EASE_IN)
	popup_tween.set_trans(Tween.TRANS_SINE)
	
	await popup_tween.finished
	hide_buttons()
	
	self.hide()

func show_buttons(buttons: Array[int]) -> void:
	var idx: int = -1
	var show_all: bool = buttons.is_empty()
	for btn in $ButtonContainer.get_children():
		assert(btn is Button or btn is TextureButton)
		idx += 1
		btn.visible = show_all or (idx in buttons)

func hide_buttons() -> void:
	var idx: int = -1
	for btn in $ButtonContainer.get_children():
		assert(btn is Button or btn is TextureButton)
		idx += 1
		btn.show()
