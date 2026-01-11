extends CharacterBody2D
class_name Player

enum POSE {
	NONE = -1,
	IDLE,
	WALK,
	JUMP,
	GRAB, # 보류
	ATTACK,
	CNT
}

signal pose_in(POSE)
signal pose_out(POSE)
signal dir_ch(int)

@export var speed: float = 80.0
@export var jump_velocity: float = -400.0
@export var parts: Array[AnimPart] = []
var gravity: float = 900
const MAX_JUMPS: int = 2
var jumps_left: int = MAX_JUMPS

var last_dir: int = 1:
	set(v):
		if v == 1 or v == -1:
			last_dir = v
			dir_ch.emit(last_dir)

var hp: int = 3:
	set(v):
		if v < 0:
			v = 0
		hp = v

func _ready() -> void:
	for part: AnimPart in parts:
		pose_in.connect(part.posed_in)
		pose_out.connect(part.posed_out)

		dir_ch.connect(part.turn_around)
	
	pose_in.emit(POSE.IDLE)
	last_dir = 1


func _physics_process(delta: float) -> void:
	var axis := Input.get_axis(&"A", &"D")
	if axis != 0 and last_dir != int(axis):
		last_dir = int(axis)
		$Sprites.scale.x = last_dir
	velocity.x = axis * speed
	
	# 키 입력 여부에 따른 WALK 이벤트
	if axis != 0:
		pose_in.emit(POSE.WALK)
		dir_ch.emit(last_dir)
	else:
		pose_out.emit(POSE.WALK)

	if is_on_floor() and jumps_left != MAX_JUMPS:
		jumps_left = MAX_JUMPS
		if velocity.y > 0.0:
			velocity.y = 0.0
		pose_out.emit(POSE.JUMP)
	else:
		velocity.y += gravity * delta

	if Input.is_action_just_pressed(&"SpaceBar") and jumps_left > 0:
		velocity.y = jump_velocity
		jumps_left -= 1
		
		pose_in.emit(POSE.JUMP)

	move_and_slide()
