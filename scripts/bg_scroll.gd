extends Control

@onready var sprite: Sprite2D = $Sprite

var accum: float = 0.0

func _ready() -> void:
	set_process(true)

func _process(delta: float) -> void:
	accum += 100 * delta
	sprite.region_rect.position.y = fposmod(accum, sprite.texture.get_height())
