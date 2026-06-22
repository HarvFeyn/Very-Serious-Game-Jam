extends Node2D

const PROGRESS_PER_ALTERNATION: float = 0.05
const DECAY_PER_SECOND: float = 0.1
const EXIT_DELAY: float = 1.0
const NOTE_STEP: float = 0.1
const POST_COMPLETION_COOLDOWN: float = 2.0

@export var success_sound: AudioStream
@export var note_sounds: Array[AudioStream] = []

var player_in_range: bool = false
var _is_active: bool = false
var _is_on_cooldown: bool = false
var _progress: float = 0.0
var _last_direction: int = 0
var _player_ref: CharacterBody2D
var _next_note_index: int = 0

func _ready() -> void:
	$InteractionArea.body_entered.connect(_on_body_entered)
	$InteractionArea.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		if not _is_active and not _is_on_cooldown:
			EventBus.interaction_available.emit("Press E to use wheel")

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		if not _is_active and not _is_on_cooldown:
			EventBus.interaction_unavailable.emit()

func _process(delta: float) -> void:
	if player_in_range and not _is_active and not _is_on_cooldown and Input.is_action_just_pressed("interact"):
		_start_wheel_mode()
		return

	if _is_active:
		_handle_wheel_input()
		_apply_decay(delta)

func _start_wheel_mode() -> void:
	_is_active = true
	_progress = 0.0
	_last_direction = 0
	_next_note_index = 0
	_player_ref = get_tree().get_first_node_in_group("player") as CharacterBody2D
	_player_ref.is_in_wheel_mode = true

	EventBus.interaction_unavailable.emit()
	EventBus.wheel_started.emit()
	EventBus.wheel_progress_changed.emit(_progress)

func _handle_wheel_input() -> void:
	var direction: int = 0
	if Input.is_action_just_pressed("move_left"):
		direction = -1
	elif Input.is_action_just_pressed("move_right"):
		direction = 1

	if direction == 0:
		return

	if _last_direction != 0 and direction != _last_direction:
		var previous_progress: float = _progress
		_progress = clamp(_progress + PROGRESS_PER_ALTERNATION, 0.0, 1.0)
		EventBus.wheel_progress_changed.emit(_progress)
		_check_note_threshold(previous_progress)

		if _progress >= 1.0:
			_complete_wheel()
			return

	_last_direction = direction

func _check_note_threshold(previous_progress: float) -> void:
	var next_threshold: float = (_next_note_index + 1) * NOTE_STEP

	if _progress >= next_threshold and previous_progress < next_threshold:
		if _next_note_index < note_sounds.size():
			AudioManager.play_sfx(note_sounds[_next_note_index])
			_next_note_index += 1

func _apply_decay(delta: float) -> void:
	if _progress <= 0.0:
		return
	_progress = max(_progress - DECAY_PER_SECOND * delta, 0.0)
	EventBus.wheel_progress_changed.emit(_progress)

func _complete_wheel() -> void:
	_is_active = false
	_is_on_cooldown = true
	PowerManager.recharge()
	EventBus.wheel_completed.emit()
	AudioManager.play_sfx(success_sound)

	await get_tree().create_timer(EXIT_DELAY).timeout
	_player_ref.is_in_wheel_mode = false

	await get_tree().create_timer(POST_COMPLETION_COOLDOWN - EXIT_DELAY).timeout
	_is_on_cooldown = false

	if player_in_range:
		EventBus.interaction_available.emit("Press E to use wheel")
