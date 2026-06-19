extends Node

var main: MainScene

func get_main() -> MainScene:
	if main == null:
		push_error("Main_Scene n'est pas encore initialisée !")
	return main

func pause() -> void:
	get_tree().paused = true

func resume() -> void:
	get_tree().paused = false

func toggle_pause() -> void:
	get_tree().paused = not get_tree().paused

func quit() -> void:
	get_tree().quit()

func set_fullscreen(value: bool) -> void:
	if value:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	SettingsManager.set_setting("video", "fullscreen", value)
