class_name MainScene
extends Node

@onready var scene_container: Node = $SceneContainer
const MUSIC: AudioStreamInteractive = preload("res://audio/music/adaptative_music.tres")

func _ready() -> void:
	Globals.main = self
	Globals.set_fullscreen(SettingsManager.get_setting("video", "fullscreen"))
	SceneManager.init(scene_container)
	AudioManager.play_interactive_music(MUSIC)
