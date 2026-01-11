class_name ObstacleGenerator extends PoissonGenerator


func _ready() -> void:
	super._ready()
	$Tick.wait_time = 1
	$Tick.disconnect(&"timeout", generate)
	$Tick.connect(&"timeout", new_generate)

func new_generate() -> void:
	for _i in _cnt_per_tick:
		var new_obs: Obstacle = _gen_obstacle()
		
		new_obs.position = position + Vector2.DOWN * screen_padding + Vector2.RIGHT * randf_range(new_obs.radius + 10, Utility.world_y - new_obs.radius - 10)
		new_obs.show()
	
	$Tick.start()
