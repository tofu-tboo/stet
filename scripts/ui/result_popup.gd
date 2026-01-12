extends CanvasLayer

@onready var base: NinePatchRect = $ResultPopup/Base
@onready var effect_rect: ColorRect = $ResultPopup/Effect

var _tween: Tween

func _ready() -> void:
	hide()
	# 일시정지 상태에서도 팝업이 작동하도록 설정
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# 팝업 애니메이션을 위한 피벗 설정 (중앙 기준 스케일링)
	base.pivot_offset = base.size / 2
	
	# 쉐이더 재질 초기화 (인스턴스 독립성 보장 및 초기값 설정)
	if effect_rect.material:
		effect_rect.material = effect_rect.material.duplicate()
		(effect_rect.material as ShaderMaterial).set_shader_parameter("radius", 0.0)
	

func open() -> void:
	$ResultPopup/Base/Message.text = "The Steward fell {0} meters deep before the Rune Mist erased their name from history.".format([GlobalData.score])
	
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


func _on_re_button_pressed() -> void:
	GlobalData.init()
	SceneManager.reload_scene()
