extends GlobalPopup

func exit() -> void:
	get_tree().quit()

func re() -> void:
	%Popups._close_popup_by_ref(self)
