extends RefCounted
class_name EventHandler

func _init(owner: Node, callback_info: Dictionary[String, Callable]) -> void:
	if callback_info.is_empty():
		return
	for key: String in callback_info:
		add_action(key, callback_info[key])
	
	if owner is CollisionObject2D:
		owner.input_event.connect(func(_viewport: Node, event: InputEvent, _shape_idx: int) -> void: _proc(event))
	elif owner is Control:
		owner.gui_input.connect(_proc)

func add_action(event_name: String, action: Callable) -> void:
	if has_signal(event_name):
		connect(event_name, action)

func remove_action(event_name: String, action: Callable) -> void:
	if has_signal(event_name) and event_name in get_signal_connection_list(event_name):
		disconnect(event_name, action)

func _proc(_event: InputEvent) -> void:
	pass
