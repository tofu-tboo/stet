class_name Dock extends RefCounted

var disk: Disk
var platform: Platform

func _init(new_pos: Vector2, new_radius: float, new_platform: Platform) -> void:
	disk = Disk.new(new_pos, new_radius)
	platform = new_platform

func update() -> void:
	if platform == null:
		return
	disk.pos = platform.position
	disk.radius = platform.get_space_radius()

static func make_from(other_platform: Platform) -> Dock:
	return Dock.new(other_platform.global_position, other_platform.get_space_radius(), other_platform)
