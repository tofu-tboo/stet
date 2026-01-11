extends CharacterBody2D
class_name Player

signal hurt(cur: int)
signal dead()

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
@export var jump_velocity: float = 500.0
@export var parts: Array[AnimPart] = []
var gravity: float = 900
const MAX_JUMPS: int = 2
var jumps_left: int = MAX_JUMPS

@onready var beam: Beam = $Sprites/RHand/Stick/Tip/Beam

var _beam_active: bool = false

var last_dir: int = 1:
	set(v):
		if v == 1 or v == -1:
			last_dir = v
			dir_ch.emit(last_dir)

var hp: int = 3:
	set(v):
		if v < 0:
			v = 0
			dead.emit()
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
		velocity.y = -jump_velocity
		jumps_left -= 1
		
		pose_in.emit(POSE.JUMP)

	var buttons_active: bool = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
	if buttons_active != _beam_active:
		_beam_active = buttons_active
		beam.set_casting(_beam_active)
	
	# 빔이 활성화된 경우, 빔의 타겟을 현재 마우스 위치(Global 좌표)로 업데이트
	if _beam_active:
		beam.target_position = get_global_mouse_position()

	move_and_slide()

func _hurt(dam: int) -> void:
	hp -= dam
	hurt.emit(hp)

func sink() -> void:
	_hurt(3)
