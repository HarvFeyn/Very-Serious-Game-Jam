class_name PauseMenu
extends Control

const OPTIONS_MENU: PackedScene = preload("res://ui/menus/options_menu/options_menu.tscn")

@onready var _buttons_container: VBoxContainer = $Background/VBoxContainer
@onready var _options_container: Node = $Background/OptionsContainer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_resume_button_pressed() -> void:
	Globals.resume()
	queue_free()

func _on_options_button_pressed() -> void:
	_buttons_container.visible = false
	var options: OptionsMenu = OPTIONS_MENU.instantiate()
	options.context = SceneEnums.OptionsContext.PAUSE_MENU
	options.closed.connect(_on_options_closed)
	_options_container.add_child(options)
	options.backgroundVisibility(false)
	
func _on_options_closed() -> void:
	_buttons_container.visible = true

func _on_main_menu_button_pressed() -> void:
	AudioManager.set_music_state(MusicEnums.MusicState.MENU)
	Globals.resume()
	SceneManager.go_to_main_menu()
