extends Node2D

@export var starting_level: GameLevel
@export var starting_spawn: Marker2D

func _ready() -> void:
	LevelManager.setup($Player, $Player/Camera2D, $TransitionLayer/FadeRect, starting_level, starting_spawn)
	$Player.global_position = starting_spawn.global_position
	AudioManager.set_music_state(MusicEnums.MusicState.STRESS)
	
func _exit_tree() -> void:
	Globals.is_returning_to_menu = true
	PowerManager.full_reset()
	if AudioManager.music_playing != MusicEnums.MusicState.MENU:
		AudioManager.set_music_state(MusicEnums.MusicState.MENU)
