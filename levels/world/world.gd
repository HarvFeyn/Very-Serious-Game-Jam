extends Node2D

@export var starting_level: GameLevel
@export var starting_spawn: Marker2D

func _ready() -> void:
	LevelManager.setup(
		$Player,
		$Player/Camera2D,
		$TransitionLayer/FadeRect,
		starting_level
	)
	$Player.global_position = starting_spawn.global_position
