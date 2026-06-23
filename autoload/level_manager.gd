extends Node

const FADE_DURATION: float = 0.7
const WALK_DURATION: float = 0.7

const game_over_sound: AudioStream = preload("res://entities/player/audio/Feule.mp3")

var current_level: GameLevel
var player: CharacterBody2D
var camera: Camera2D
var fade_rect: ColorRect

var _is_transitioning: bool = false

var _starting_level: GameLevel
var _starting_spawn: Marker2D

func setup(p_player: CharacterBody2D, p_camera: Camera2D, p_fade_rect: ColorRect, starting_level: GameLevel, starting_spawn: Marker2D) -> void:
	player = p_player
	camera = p_camera
	fade_rect = p_fade_rect
	current_level = starting_level
	_starting_level = starting_level
	_starting_spawn = starting_spawn
	_activate_level(starting_level)

	EventBus.game_reset.connect(_on_game_reset)

func _on_game_reset() -> void:
	player.controls_enabled = false
	player.velocity = Vector2.ZERO
	player.is_in_wheel_mode = false
	player.is_pushing = false

	var tween_out: Tween = create_tween()
	tween_out.tween_property(fade_rect, "color:a", 1.0, 2.0)

	await get_tree().create_timer(1.0).timeout
	if game_over_sound:
		AudioManager.play_sfx(game_over_sound)

	await tween_out.finished

	player.global_position = _starting_spawn.global_position
	player.velocity = Vector2.ZERO
	current_level = _starting_level
	_activate_level(_starting_level)

	var tween_in: Tween = create_tween()
	tween_in.tween_property(fade_rect, "color:a", 0.0, 1.0)
	await tween_in.finished

	player.controls_enabled = true
	
func go_to_level_with_walk_in(player_node: CharacterBody2D, target_level: GameLevel, spawn_position: Vector2, walk_offset: Vector2) -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	_do_transition_with_walk(player_node, target_level, spawn_position, walk_offset)

func _do_transition_with_walk(player_node: CharacterBody2D, target_level: GameLevel, spawn_position: Vector2, walk_offset: Vector2) -> void:
	player_node.controls_enabled = false
	player_node.velocity = Vector2.ZERO

	var walk_tween: Tween = create_tween()
	walk_tween.tween_property(player_node, "global_position", player_node.global_position + walk_offset, WALK_DURATION)
	await walk_tween.finished

	var tween_out: Tween = create_tween()
	tween_out.tween_property(fade_rect, "color:a", 1.0, FADE_DURATION)
	await tween_out.finished

	player_node.global_position = spawn_position
	player_node.velocity = Vector2.ZERO
	current_level = target_level
	_activate_level(target_level)

	var tween_in: Tween = create_tween()
	tween_in.tween_property(fade_rect, "color:a", 0.0, FADE_DURATION)
	await tween_in.finished

	var walk_in_tween: Tween = create_tween()
	walk_in_tween.tween_property(player_node, "global_position", player_node.global_position + walk_offset, WALK_DURATION)
	await walk_in_tween.finished

	player_node.controls_enabled = true
	_is_transitioning = false

func _activate_level(level: GameLevel) -> void:
	var parent: Node = level.get_parent()
	for sibling: Node in parent.get_children():
		if sibling is GameLevel:
			var game_level_sibling: GameLevel = sibling
			var is_active: bool = (game_level_sibling == level)
			game_level_sibling.visible = is_active
			game_level_sibling.process_mode = Node.PROCESS_MODE_INHERIT if is_active else Node.PROCESS_MODE_DISABLED

	_apply_camera_limits(level)

func _apply_camera_limits(level: GameLevel) -> void:
	camera.limit_left = level.camera_limit_left
	camera.limit_right = level.camera_limit_right
	camera.limit_top = level.camera_limit_top
	camera.limit_bottom = level.camera_limit_bottom
