class_name MainMenu
extends Control

@export var frame1: Texture2D
@export var frame2: Texture2D
@export var frame_duration: float = 0.5

@onready var _bg_animated: TextureRect = $Background

var _current_frame: int = 0
var _anim_timer: float = 0.0

func _ready() -> void:
	_bg_animated.texture = frame1

func _process(delta: float) -> void:
	_anim_timer += delta
	if _anim_timer >= frame_duration:
		_anim_timer = 0.0
		_current_frame = (_current_frame + 1) % 2
		_bg_animated.texture = frame2 if _current_frame == 1 else frame1

func _on_play_pressed() -> void:
	if AudioManager.music_playing != MusicEnums.MusicState.MENU:
		AudioManager.set_music_state(MusicEnums.MusicState.MENU)
	SceneManager.go_to_game()

func _on_options_pressed() -> void:
	SceneManager.go_to_options()

func _on_credits_pressed() -> void:
	SceneManager.go_to_credits()
