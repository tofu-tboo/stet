extends Control

@onready var bgm_slider: HSlider = $Base/BGM
@onready var effect_slider: HSlider = $Base/Effect
@onready var bgm_label: Label = $Base/BGMVolume
@onready var effect_label: Label = $Base/EffectVolume
@onready var base: NinePatchRect = $Base
@onready var effect_rect: ColorRect = $Effect

var _tween: Tween

func _ready() -> void:
	hide()
	# 일시정지 상태에서도 팝업이 작동하도록 설정
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# 슬라이더 값 변경 시그널 연결
	bgm_slider.value_changed.connect(_on_bgm_value_changed)
	effect_slider.value_changed.connect(_on_effect_value_changed)
	
	# 종료 버튼 시그널 연결 (씬에 추가된 경우)
	if has_node("Base/QuitButton"):
		$Base/QuitButton.pressed.connect(_on_quit_button_pressed)
	
	if has_node("Base/CancelButton"):
		$Base/CancelButton.pressed.connect(_on_cancel_button_pressed)
	
	# 팝업 애니메이션을 위한 피벗 설정 (중앙 기준 스케일링)
	base.pivot_offset = base.size / 2
	
	# 쉐이더 재질 초기화 (인스턴스 독립성 보장 및 초기값 설정)
	if effect_rect.material:
		effect_rect.material = effect_rect.material.duplicate()
		(effect_rect.material as ShaderMaterial).set_shader_parameter("radius", 0.0)
	
	# 현재 오디오 버스 볼륨으로 슬라이더 초기화
	_init_volume("BGM", bgm_slider, bgm_label)
	_init_volume("Effect", effect_slider, effect_label)
	
	GlobalEventHandler.exit_requested.connect(open)

func _init_volume(bus_name: String, slider: HSlider, label: Label) -> void:
	var idx = AudioServer.get_bus_index(bus_name)
	if idx != -1:
		var db = AudioServer.get_bus_volume_db(idx)
		var linear = db_to_linear(db)
		slider.value = linear * 100.0
		label.text = str(int(slider.value)) + "%"

func _on_bgm_value_changed(value: float) -> void:
	_set_volume("BGM", value)
	bgm_label.text = str(int(value)) + "%"

func _on_effect_value_changed(value: float) -> void:
	_set_volume("Effect", value)
	effect_label.text = str(int(value)) + "%"

func _set_volume(bus_name: String, value: float) -> void:
	var idx = AudioServer.get_bus_index(bus_name)
	if idx != -1:
		# 0이면 Mute 처리
		if value <= 0:
			AudioServer.set_bus_mute(idx, true)
		else:
			AudioServer.set_bus_mute(idx, false)
			AudioServer.set_bus_volume_db(idx, linear_to_db(value / 100.0))

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_cancel_button_pressed() -> void:
	close()

func open() -> void:
	if _tween: _tween.kill()
	visible = true
	get_tree().paused = true
	base.scale = Vector2.ZERO
	
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(base, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	if effect_rect.material is ShaderMaterial:
		effect_rect.material.set_shader_parameter("radius", 0.0)
		_tween.tween_method(func(v): effect_rect.material.set_shader_parameter("radius", v), 0.0, 0.4, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func close() -> void:
	if _tween: _tween.kill()
	
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(base, "scale", Vector2.ZERO, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	if effect_rect.material is ShaderMaterial:
		_tween.tween_method(func(v): effect_rect.material.set_shader_parameter("radius", v), 0.4, 0.0, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	
	_tween.chain().tween_callback(func(): 
		visible = false
		get_tree().paused = false
	)
