extends Node

signal exit_requested

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not event.is_echo():
		exit_requested.emit()
