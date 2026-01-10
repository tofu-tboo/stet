extends CharacterBody2D
class_name Player

@export var speed: float = 100

var accel_vel: float = 0
var force_vel: float = 0

func _physics_process(delta: float) -> void:
	accel_vel += 300 * delta
	velocity.y = accel_vel + force_vel
	move_and_slide()
	
	if is_on_floor():
		accel_vel = 0
	
	force_vel = 0

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed(&"A"):
		velocity.x = -speed
	elif Input.is_action_just_released(&"A"):
		velocity.x = 0
	
	if Input.is_action_just_pressed(&"D"):
		velocity.x = speed
	elif Input.is_action_just_released(&"D"):
		velocity.x = 0
	
	# TODO: 내려가기
	if Input.is_action_just_pressed(&"S"):
		pass
	elif Input.is_action_just_released(&"S"):
		pass
	
	if Input.is_action_just_pressed(&"SpaceBar"):
		force_vel = -800
