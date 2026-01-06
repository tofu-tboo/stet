extends GlobalPopup

func exit() -> void:
	get_tree().quit()

func go_update() -> void:
	print("market")

func show_buttons(_buttons: Array[int]) -> void: null

func hide_buttons() -> void: null
