extends GlobalPopup


func _ready() -> void:
	super()
	$EffectSound/Slider.value = Data.e_vol
	$BGM/Slider.value = Data.b_vol
	
	set_effect_sound_volume()
	set_bgm_volume()
	
func set_effect_sound_volume() -> void:
	var value: float = $EffectSound/Slider.value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effect"), linear_to_db(value))
	Data.e_vol = value

func set_bgm_volume() -> void:
	var value: float = $BGM/Slider.value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BGM"), linear_to_db(value))
	Data.b_vol = value

func show_buttons(_buttons: Array[int]) -> void: null

func hide_buttons() -> void: null
