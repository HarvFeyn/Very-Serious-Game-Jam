class_name MainMenu
extends Control

@onready var background: ColorRect = $ColorRect

func _ready() -> void:
	background.color = GameColors.SECONDARY

func _on_play_pressed() -> void:
	AudioManager.set_music_state(MusicEnums.MusicState.MENU)
	SceneManager.go_to_game()

func _on_options_pressed() -> void:
	SceneManager.go_to_options()

func _on_credits_pressed() -> void:
	SceneManager.go_to_credits()
