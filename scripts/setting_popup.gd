extends Control

@onready var bgm_slider: HSlider = $Base/BGM
@onready var effect_slider: HSlider = $Base/Effect
@onready var bgm_label: Label = $Base/BGMVolume
@onready var effect_label: Label = $Base/EffectVolume

func _ready() -> void:
	# 슬라이더 값 변경 시그널 연결
	bgm_slider.value_changed.connect(_on_bgm_value_changed)
	effect_slider.value_changed.connect(_on_effect_value_changed)
	
	# 종료 버튼 시그널 연결 (씬에 추가된 경우)
	if has_node("Base/QuitButton"):
		$Base/QuitButton.pressed.connect(_on_quit_button_pressed)
		
	if has_node("Base/CancelButton"):
		$Base/CancelButton.pressed.connect(_on_cancel_button_pressed)
	
	# 현재 오디오 버스 볼륨으로 슬라이더 초기화
	_init_volume("BGM", bgm_slider, bgm_label)
	_init_volume("Effect", effect_slider, effect_label)

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
	visible = false