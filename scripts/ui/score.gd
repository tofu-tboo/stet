extends Label

func add_score() -> void:
	GlobalData.score += 1
	text = str(GlobalData.score)
