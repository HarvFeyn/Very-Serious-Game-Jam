extends Node2D

@onready var _particles: CPUParticles2D = $LitterParticles

@export var target_door: NodePath
@export var interaction_sound: AudioStream
@export var interaction_duration: float = 10.0
@export var player_litter_offset: Vector2 = Vector2(5, -50)

var _player_in_range: bool = false
var _is_used: bool = false
var _player_ref: CharacterBody2D = null

func _ready() -> void:
	$InteractionArea.body_entered.connect(_on_body_entered)
	$InteractionArea.body_exited.connect(_on_body_exited)
	EventBus.game_reset.connect(_on_game_reset)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = true
		_player_ref = body as CharacterBody2D
		if not _is_used:
			if Globals.pee_level >= 1.0:
				EventBus.interaction_available.emit("Press E to interact")
			else:
				EventBus.interaction_available.emit("...")

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
		if not _is_used:
			EventBus.interaction_unavailable.emit()

func _process(_delta: float) -> void:
	if _player_in_range and not _is_used and Globals.pee_level >= 1.0 \
			and Input.is_action_just_pressed("interact"):
		_trigger()

func _trigger() -> void:
	_is_used = true
	EventBus.interaction_unavailable.emit()
	_player_ref.is_in_lock_mode = true
	_player_ref.global_position = global_position + player_litter_offset
	_player_ref.sprite.flip_h = true
	_player_ref.sprite.play("run")
	_particles.emitting = true
	
	if interaction_sound:
		AudioManager.play_sfx(interaction_sound)

	var tween: Tween = create_tween()
	tween.tween_method(_drain_pee, Globals.pee_level, 0.0, 2.0)
	tween.set_parallel(true)
	tween.tween_method(_set_direction_y, -0.5, -1.0, interaction_duration)
	tween.tween_property(_particles, "initial_velocity_min", 400.0, interaction_duration)
	tween.tween_property(_particles, "initial_velocity_max", 500.0, interaction_duration)

	await get_tree().create_timer(interaction_duration).timeout
	
	PowerManager.advance_tier()
	_particles.emitting = false
	
	_player_ref.sprite.stop()
	_player_ref.is_in_lock_mode = false

	var door: StaticBody2D = get_node(target_door) as StaticBody2D
	door.solve_puzzle()

func _on_game_reset() -> void:
	_is_used = false

func _drain_pee(value: float) -> void:
	Globals.pee_level = value
	EventBus.pee_changed.emit(value)

func _set_direction_y(value: float) -> void:
	_particles.direction = Vector2(1.0, value)
