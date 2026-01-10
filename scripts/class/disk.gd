class_name Disk extends RefCounted

var pos: Vector2
var radius: float

func _init(new_pos: Vector2, new_radius: float) -> void:
	pos = new_pos
	radius = new_radius

static func gap(disk1: Disk, disk2: Disk) -> float:
	return (disk1.pos - disk2.pos).length() - disk1.radius - disk2.radius
