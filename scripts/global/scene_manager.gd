extends Node

const path = "res://scenes/"
var current : String

func load_scene(next: String) -> bool:
	if ".." in path or "./" in path:
		return false
	elif !FileAccess.file_exists(path + next + ".tscn"):
		return false
	
	current = path + next + ".tscn"
	
	# ScreenEffect.on()
	# await ScreenEffect.fade_out(Color("#101010"))
	# ScreenEffect.off()
	change_scene_to_packed(load("res://scenes/loading.tscn") as PackedScene)
	return true

func load_game_mode(next: String) -> void:
	Data.game_mode = next
	
	current = path + "main.tscn"
	
	# ScreenEffect.on()
	# await ScreenEffect.fade_out(Color("#101010"))
	# ScreenEffect.off()
	change_scene_to_packed(load("res://scenes/loading.tscn") as PackedScene)

func change_scene_to_packed(packed_scene: PackedScene, effect: String = "none") -> void:
	var scene_instance: Node = packed_scene.instantiate()
	
	self.add_child(scene_instance)
	while self.get_child_count() > 1:
		self.remove_child(self.get_child(0))
	
	if effect == "none":
		return
	
	# ScreenEffect.on()
	
	match effect:
		"none":
			pass
		"fade_in":
			# await ScreenEffect.fade_in(Color("#101010"))
            pass
	# ScreenEffect.off()
