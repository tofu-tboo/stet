extends RefCounted
class_name Queue

var _data: Array = []

func push(value: Variant) -> void:
	_data.push_back(value)

func pop() -> Variant:
	if is_empty():
		return null
	return _data.pop_front()

func front() -> Variant:
	if is_empty():
		return null
	return _data[0]

func size() -> int:
	return _data.size()

func is_empty() -> bool:
	return _data.is_empty()

func clear() -> void:
	_data.clear()
