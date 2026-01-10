extends Control

@onready var sprite: Sprite2D = $Sprite
var speed: float = 100.0

func _ready() -> void:
	set_process(false)

func _physics_process(delta: float) -> void:
	sprite.region_rect.position.y += floor(delta * speed)
	
	if sprite.region_rect.position.y >= 2 ** 16:
		sprite.region_rect.position.y -= 2 ** 16
