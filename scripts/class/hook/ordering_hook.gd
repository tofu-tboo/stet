class_name OrderingHook extends Object

enum { NONE, PLATFORM, PLAYER, ENEMY, PROJECTILE, CNT } # ordering

static func assign_order(target: Node2D, type: int) -> void:
	target.z_index = type
