extends ColorRect

#@export var init_cutoff: float = 0.0
var _tween: Tween

signal closed()
#func _ready() -> void:
	#material.set_shader_parameter("curoff", init_cutoff)

func close() -> void:
	if _tween: _tween.kill()
	_tween = create_tween()
	
	if material is ShaderMaterial:
		# 위에서 아래로 내려옴 (화면 가림)
		_tween.tween_method(func(v): (material as ShaderMaterial).set_shader_parameter("cutoff", v), 0.0, 1.2, 2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		
		_tween.finished.connect(
			func():
				closed.emit()
		)

func open() -> void:
	if _tween: _tween.kill()
	_tween = create_tween()
	
	if material is ShaderMaterial:
		# 아래에서 위로 걷힘 (화면 드러냄)
		_tween.tween_method(func(v): (material as ShaderMaterial).set_shader_parameter("cutoff", v), 1.2, 0.0, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
