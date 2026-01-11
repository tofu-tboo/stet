class_name Platform extends AnimatableBody2D

enum { FLOATING }

signal state_changed() # frog to land
signal collapse() # frog to drown

var has_state: bool = true
var can_collapse: bool = true

func get_space_radius() -> float:
	return 0.0

func landed(_player: Player) -> void:
	pass

func takeoff(_player: Player) -> void:
	pass

func _enter_tree() -> void:
	OrderingHook.assign_order(self, OrderingHook.PLATFORM)
