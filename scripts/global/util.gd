extends Node

var world_x: int = ProjectSettings.get_setting("display/window/size/viewport_width")
var world_y: int = ProjectSettings.get_setting("display/window/size/viewport_height")
var world_area: int = world_x * world_y
var world_size: Vector2i = Vector2i(world_x, world_y)
var world_rect: Rect2 = Rect2(0, 0, world_x, world_y)
var world_center: Vector2 = Vector2(world_x / 2, world_y / 2)

'''
정규분포 랜덤, 4σ이내로 범위 clamp
'''
func rand_normal(mean: float = 0.0, stddev: float = 1.0) -> float:
	var u1: float = randf()
	var u2: float = randf()
	var z0: float = sqrt(-2.0 * log(u1)) * cos(2.0 * PI * u2)
	
	return clamp(z0 * stddev + mean, mean - 4 * stddev, mean + 4 * stddev)

func erase_subarray(arr: Array, sub: Array) -> void:
	var new_arr: Array = []
	for element: Variant in arr:
		if not sub.has(element):
			new_arr.append(element)
	
	arr.clear()
	arr.append_array(new_arr)
	
func sleep(time: float) -> void:
	await get_tree().create_timer(time).timeout
