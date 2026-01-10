extends Node

func how_many(group: StringName) -> int:
	return get_tree().get_nodes_in_group(group).size()

func what(group: StringName) -> Array[Node]:
	return get_tree().get_nodes_in_group(group)
