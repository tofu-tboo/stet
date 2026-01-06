extends EventHandler
class_name DragEventHandler

'''
포인터 1개의 움직임과 관련된 이벤트만 모아놓음.
'''

signal range_exited()
signal range_entered()
signal move(pointer: Vector2)

var range_squared: float
var start_pos: Vector2
var downed: bool = false
var out: bool = false

func _init(owner: Node, event_range: float, callback_info: Dictionary) -> void:
	super(owner, callback_info)
	range_squared = event_range ** 2

func _proc(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			start_pos = event.position
			downed = true
		else:
			downed = false
	elif downed and (event is InputEventScreenDrag or event is InputEventMouseMotion):
		move.emit(event.position)
		if not out and (event.position - start_pos).length_squared() >= range_squared:
			out = true
			range_exited.emit()
		elif out and (event.position - start_pos).length_squared() < range_squared:
			out = false
			range_entered.emit()

func cancel() -> void:
	downed = false
