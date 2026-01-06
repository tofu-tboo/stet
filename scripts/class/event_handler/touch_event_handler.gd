extends EventHandler
class_name TouchEventHandler

'''
포인터 다운, 포인터 업, 클릭, 홀드, 더블 클릭
'''

signal down()
signal up()
signal click()
signal hold()
signal double_click()

var down_time: int = 0
var downed: bool = false # 포인터 down 여부
var last_click: int = 0
var stable: bool = false # 포인터 제자리 여부

func _init(owner: Node, callback_info: Dictionary) -> void:
	super(owner, callback_info)
	
	owner.mouse_exited.connect(on_mouse_exited)

func _proc(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			downed = true
			stable = true
			down_time = Time.get_ticks_msec()
			_check_hold()
			down.emit()
		else:
			downed = false
			_check_click(Time.get_ticks_msec() - down_time)
			up.emit()
	elif event is InputEventMouseMotion or event is InputEventScreenDrag:
		stable = false

func on_mouse_exited() -> void:
	downed = false

func _check_hold() -> void:
	while true:
		if not downed or not stable:
			return
		elif Time.get_ticks_msec() - down_time >= 500:
			hold.emit()
			return
		await Utility.sleep(0.05)

func _check_click(elapsed: int) -> void:
	if downed:
		return
	elif elapsed <= 200:
		click.emit()
		
		if Time.get_ticks_msec() - last_click <= 300:
			double_click.emit()
		else:
			last_click = Time.get_ticks_msec()
		
		
