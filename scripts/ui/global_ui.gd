extends Node
signal popup_closed
signal popup_opened

enum POPUP { NETWORK, UPDATE, SETTINGS, MODE_ERR, _CNT_ }

static var screen_x: int = ProjectSettings.get_setting("display/window/size/viewport_width") :
	set(v):
		if (v <= 0):
			return
		screen_x = v
static var screen_y: int = ProjectSettings.get_setting("display/window/size/viewport_height") :
	set(v):
		if (v <= 0):
			return
		screen_y = v

@onready var center_marker : Control = $CenterMarker


func show_popup(popup_type: POPUP, buttons: Array[int] = []) -> void:
	'''transfer instr and emit signal'''
	await $Popups.show_popup(popup_type, buttons)
	
	popup_opened.emit()
	
func close_popup(popup_type: POPUP) -> void:
	'''transfer instr and emit signal'''
	await $Popups.close_popup(popup_type)
	
	popup_closed.emit()

func close_all_popup() -> void:
	'''transfer instr and emit signal'''
	await $Popups.close_all_popup()
	
	popup_closed.emit()

func show_settings() -> void:
	show_popup(POPUP.SETTINGS)
