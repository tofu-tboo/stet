extends CanvasLayer

func _ready() -> void:
	$Panel.modulate.a = 0

func show_popup(popup_type: GlobalUI.POPUP, buttons: Array[int]) -> void:
	_deal_dynamic_popup() # Dynamic load popups which are not needed to be static.
	var path: NodePath = NodePath("Plates/" + str(GlobalUI.POPUP.keys()[popup_type]))
	var popup: Node = get_node_or_null(path) as GlobalPopup
	if popup == null:
		return
	assert(popup != null)
	
	var panel_tween: Tween = create_tween()
	
	$Panel.show()
	
	panel_tween.tween_property($Panel, "modulate:a", 1, 0.6)
	panel_tween.set_ease(Tween.EASE_OUT)
	panel_tween.set_trans(Tween.TRANS_SINE)
	
	await popup.display(buttons, 0.6)
	
	await panel_tween.finished

func close_all_popup() -> void:
	for popup in $Plates.get_children():
		await _close_popup_by_ref(popup as GlobalPopup)
func close_popup(popup_type: GlobalUI.POPUP) -> void:
	var path: NodePath = NodePath("Plates/" + str(GlobalUI.POPUP.keys()[popup_type]))
	await _close_popup_by_ref(get_node_or_null(path) as GlobalPopup)

func _close_popup_by_ref(popup: GlobalPopup) -> void:
	if popup == null:
		return
	assert(popup != null)
	
	var panel_tween: Tween = create_tween()
	
	panel_tween.tween_property($Panel, "modulate:a", 0, 0.6)
	panel_tween.set_ease(Tween.EASE_OUT)
	panel_tween.set_trans(Tween.TRANS_SINE)
	
	popup.conceal()
	
	await panel_tween.finished
	$Panel.hide()

func _deal_dynamic_popup() -> void:
	pass
