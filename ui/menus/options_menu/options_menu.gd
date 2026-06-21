class_name OptionsMenu
extends Control

@onready var _master_slider: HSlider = $VBoxContainer/MasterSlider
@onready var _music_slider: HSlider = $VBoxContainer/MusicSlider
@onready var _sfx_slider: HSlider = $VBoxContainer/SFXSlider
@onready var backGround: ColorRect = $ColorRect

var context: SceneEnums.OptionsContext = SceneEnums.OptionsContext.MAIN_MENU
signal closed

func _ready() -> void:
	backGround.color = GameColors.SECONDARY
	_master_slider.value = AudioManager.get_volume(AudioManager.BUS_MASTER)
	_music_slider.value = AudioManager.get_volume(AudioManager.BUS_MUSIC)
	_sfx_slider.value = AudioManager.get_volume(AudioManager.BUS_SFX)
	backgroundVisibility(true)

func _on_master_slider_value_changed(value: float) -> void:
	AudioManager.set_volume(AudioManager.BUS_MASTER, value)

func _on_music_slider_value_changed(value: float) -> void:
	AudioManager.set_volume(AudioManager.BUS_MUSIC, value)

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioManager.set_volume(AudioManager.BUS_SFX, value)

func _on_back_button_pressed() -> void:
	SettingsManager.save()
	match context:
		SceneEnums.OptionsContext.MAIN_MENU:
			SceneManager.go_to_main_menu()
		SceneEnums.OptionsContext.PAUSE_MENU:
			closed.emit()
			queue_free()

@warning_ignore("shadowed_variable_base_class")
func backgroundVisibility(visible: bool) -> void:
	backGround.visible = visible
