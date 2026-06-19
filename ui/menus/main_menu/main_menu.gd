class_name MainMenu
extends Control

func _on_play_pressed() -> void:
	AudioManager.set_music_state(MusicEnums.MusicState.TENSE)
	SceneManager.go_to_game()
	
func _on_options_pressed() -> void:
	SceneManager.go_to_options()
