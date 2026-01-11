extends HBoxContainer

var hearts: Array[TextureRect] = []

func _ready() -> void:
	for ch: TextureRect in get_children():
		hearts.append(ch)
	
	hearts.reverse()

func display_hp(val: int) -> void:
	for i in 3 - val:
		hearts[i].texture = load("res://textures/ui/hp_empty.png")
	for i in val:
		hearts[2 - i].texture = load("res://textures/ui/hp_full.png")
