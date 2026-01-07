extends CanvasLayer

const _col_def: Array[Color] = [Color8(62, 39, 35), Color8(245, 245, 220)]
const _col_crimson_shadow: Array[Color] = [Color8(34, 40, 49), Color8(190, 49, 68)]
const _col_pumpkin_navy: Array[Color] = [Color8(27, 38, 44), Color8(255, 180, 65)]
const colors: Dictionary[String, Array] = { "default": _col_def, "crimson": _col_crimson_shadow, "crimson_shadow": _col_crimson_shadow, "pumpkin": _col_pumpkin_navy, "pumpkin_navy": _col_pumpkin_navy }

func change_to(coln: String) -> void:
	var mat: ShaderMaterial =  $FullWindow.material
	var col: Array[Color] = colors.get(coln)
	
	if col == null:
		return
	
	mat.set_shader_parameter(&"color1", col[0])
	mat.set_shader_parameter(&"color1", col[1])
