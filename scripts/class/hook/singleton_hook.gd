class_name SingletonHook extends Object

'''
노드가 초기화되는 콜백에서 이용한다.
SingletonHook.sure_only_one_load(self)
'''

static var ids: Dictionary[int, bool] = {}

static func sure_only_one_load(target: Node) -> void:
	var script: Script = target.get_script()
	if script == null:
		return
	
	var id: int = script.get_instance_id()
	if not ids.has(id):
		ids[id] = true
	else:
		target.queue_free()
