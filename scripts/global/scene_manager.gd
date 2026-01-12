extends Node

const SCENE_PATH = "res://scenes/"

var _curtain: ColorRect

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_init_curtain()

func _init_curtain() -> void:
	# 씬 전환 효과를 위한 CanvasLayer 및 Curtain 생성
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 890 # UI 최상단에 위치
	add_child(canvas_layer)
	
	_curtain = ColorRect.new()
	_curtain.color = Color.BLACK
	_curtain.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_curtain.mouse_filter = Control.MOUSE_FILTER_IGNORE # 평소에는 입력 통과
	
	# Curtain 스크립트 및 쉐이더 로드
	_curtain.set_script(load("res://scripts/curtain.gd"))
	
	var mat = ShaderMaterial.new()
	mat.shader = load("res://shaders/curtain.gdshader")
	
	# 쉐이더 작동을 위한 노이즈 텍스처 생성
	var noise = FastNoiseLite.new()
	noise.frequency = 0.02
	var noise_tex = NoiseTexture2D.new()
	noise_tex.noise = noise
	mat.set_shader_parameter("noise_tex", noise_tex)
	mat.set_shader_parameter("cutoff", 0.0) # 초기 상태: 열림
	
	_curtain.material = mat
	canvas_layer.add_child(_curtain)

func change_scene(scene_name: String) -> void:
	var path = SCENE_PATH + scene_name + ".tscn"
	
	# 1. 커튼 닫기 (화면 가림)
	_curtain.mouse_filter = Control.MOUSE_FILTER_STOP # 전환 중 입력 차단
	_curtain.close()
	await _curtain.closed
	
	# 2. 씬 전환
	get_tree().change_scene_to_file(path)
	
	# 3. 커튼 열기 (화면 드러냄)
	_curtain.open()
	
	# 애니메이션 시간(2초) 대기 후 입력 차단 해제
	await get_tree().create_timer(2.0).timeout
	_curtain.mouse_filter = Control.MOUSE_FILTER_IGNORE

func reload_scene() -> void:
	_curtain.mouse_filter = Control.MOUSE_FILTER_STOP
	_curtain.close()
	await _curtain.closed
	
	get_tree().reload_current_scene()
	
	get_tree().paused = false
	_curtain.open()
	await get_tree().create_timer(2.0).timeout
	_curtain.mouse_filter = Control.MOUSE_FILTER_IGNORE
