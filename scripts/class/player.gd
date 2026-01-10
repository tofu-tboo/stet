extends CharacterBody2D
class_name Player

@export var speed: float = 80.0
@export var jump_velocity: float = -400.0
var gravity: float = 900
const MAX_JUMPS: int = 2
var jumps_left: int = MAX_JUMPS

func _physics_process(delta: float) -> void:
	var axis := Input.get_axis(&"A", &"D")
	velocity.x = axis * speed

	if is_on_floor():
		jumps_left = MAX_JUMPS
		if velocity.y > 0.0:
			velocity.y = 0.0
	else:
		velocity.y += gravity * delta

	if Input.is_action_just_pressed(&"SpaceBar") and jumps_left > 0:
		velocity.y = jump_velocity
		jumps_left -= 1

	move_and_slide()
