extends CanvasLayer

@export var center_anchor: NodePath
@export var popup_root: NodePath = NodePath(".")
@export var popup_scenes: Dictionary # key: String -> PackedScene

var _queue: Queue = Queue.new()
var _processing: bool = false
var _current_popup: GlobalPopup
var _active_request: Dictionary = {}
var _popup_cache: Dictionary = {} # key -> GlobalPopup instance

func show_popup(popup_key: String, buttons: Array[int] = []) -> void:
	var req: Dictionary = { "key": popup_key, "buttons": buttons, "done": false }
	_queue.push(req)
	_ensure_processing()
	while not req.done:
		await get_tree().process_frame

func close_popup(popup_key: String) -> void:
	if _current_popup != null and _active_request.get("key", "") == popup_key:
		await _close_popup_by_ref(_current_popup)

func close_all_popup() -> void:
	while not _queue.is_empty():
		var pending: Variant = _queue.pop()
		if pending is Dictionary:
			pending.done = true
	if _current_popup != null:
		await _close_popup_by_ref(_current_popup)
	for popup in _popup_cache.values():
		if popup is GlobalPopup and popup != _current_popup:
			await _close_popup_by_ref(popup)

func _ensure_processing() -> void:
	if _processing:
		return
	_processing = true
	call_deferred("_process_queue")

func _process_queue() -> void:
	while not _queue.is_empty():
		var req: Dictionary = _queue.pop()
		var popup := _get_or_instantiate(req.key)
		if popup == null:
			req.done = true
			continue
		if not popup.close_requested.is_connected(_on_popup_close_requested):
			popup.close_requested.connect(_on_popup_close_requested)
		
		_active_request = req
		_current_popup = popup
		
		await _play_overlay_show()
		await popup.display(req.buttons, 0.6, _get_center_y())
		await _wait_until_closed(popup)
		await _play_overlay_hide()
		
		req.done = true
	
	_active_request.clear()
	_current_popup = null
	_processing = false

func _close_popup_by_ref(popup: GlobalPopup) -> void:
	if popup == null:
		return
	await popup.conceal()
	if _current_popup == popup:
		_current_popup = null
		if _active_request.has("done"):
			_active_request["done"] = true

func _wait_until_closed(popup: GlobalPopup) -> void:
	while _current_popup == popup:
		await get_tree().process_frame

func _play_overlay_show() -> void:
	# Overlay를 사용하지 않는 규칙에 따라 비워 둡니다.
	# 필요하면 여기서 별도 애니메이션/효과를 구현하세요.
	pass

func _play_overlay_hide() -> void:
	# Overlay를 사용하지 않는 규칙에 따라 비워 둡니다.
	# 필요하면 여기서 별도 애니메이션/효과를 구현하세요.
	pass

func _on_popup_close_requested(popup: GlobalPopup) -> void:
	await _close_popup_by_ref(popup)

func _get_or_instantiate(popup_key: String) -> GlobalPopup:
	if _popup_cache.has(popup_key):
		return _popup_cache[popup_key] as GlobalPopup
	
	if not popup_scenes.has(popup_key):
		return null
	
	var ps: PackedScene = popup_scenes[popup_key]
	if ps == null:
		return null
	
	var inst := ps.instantiate()
	if inst == null or not (inst is GlobalPopup):
		return null
	
	_get_popup_root().add_child(inst)
	_popup_cache[popup_key] = inst
	return inst as GlobalPopup

func _get_center_y() -> float:
	if center_anchor != NodePath(""):
		var center_node := get_node_or_null(center_anchor)
		if center_node is CanvasItem:
			return (center_node as CanvasItem).global_position.y
	return get_viewport().size.y * 0.5

func _get_popup_root() -> Node:
	var root := get_node_or_null(popup_root)
	return root if root != null else self
