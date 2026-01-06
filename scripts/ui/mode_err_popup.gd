extends GlobalPopup

func exit() -> void:
	%Popups._close_popup_by_ref(self)
	GameScene.load_scene("main_menu")

func show_buttons(_buttons: Array[int]) -> void: null

func hide_buttons() -> void: null
