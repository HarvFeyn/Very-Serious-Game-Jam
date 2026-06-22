extends Node2D

@export var starting_level: GameLevel
@export var starting_spawn: Marker2D

func _ready() -> void:
	LevelManager.setup($Player, $Player/Camera2D, $TransitionLayer/FadeRect, starting_level, starting_spawn)
	$Player.global_position = starting_spawn.global_position

func _exit_tree() -> void:
	PowerManager.full_reset()
