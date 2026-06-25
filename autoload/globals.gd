extends Node

var main: MainScene
var pee_level: float = 0.0
var jump_hint_permanently_dismissed: bool = false
var is_returning_to_menu: bool = false

func _ready() -> void:
	EventBus.game_reset.connect(reset_pee)

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

func reset_pee() -> void:
	pee_level = 0.0
	EventBus.pee_changed.emit(pee_level)
