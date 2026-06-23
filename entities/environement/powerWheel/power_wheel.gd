extends Node2D

const WHEEL_ROTATION_SPEED: float = TAU / 10.0

@onready var _back_sprite: Sprite2D = $Back
@onready var _wheel_sprite: Sprite2D = $Wheel
@onready var _key_hints: Node2D = $KeyHints
@onready var _key_left: Node2D = $KeyHints/KeyLeft
@onready var _key_right: Node2D = $KeyHints/KeyRight

const PROGRESS_PER_ALTERNATION: float = 0.015
const DECAY_PER_SECOND: float = 0.05
const EXIT_DELAY: float = 1.0
const NOTE_STEP: float = 0.05
const POST_COMPLETION_COOLDOWN: float = 2.0
const ANIM_FPS_MIN: float = 2.0
const ANIM_FPS_MAX: float = 20.0
const PLAYER_WHEEL_ROTATION: float = 0.3

@export var success_sound: AudioStream
@export var note_sounds: Array[AudioStream] = []
@export var player_wheel_offset: Vector2 = Vector2(55, 40)

var player_in_range: bool = false
var _is_active: bool = false
var _is_on_cooldown: bool = false
var _progress: float = 0.0
var _last_direction: int = 0
var _player_ref: CharacterBody2D
var _next_note_index: int = 0
var _prompt: String = "Press E to spin the wheel"

func _ready() -> void:
	$InteractionArea.body_entered.connect(_on_body_entered)
	$InteractionArea.body_exited.connect(_on_body_exited)
	_key_hints.visible = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		if not _is_active and not _is_on_cooldown:
			EventBus.interaction_available.emit(_prompt)

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
		
	if _progress > 0.0 or PowerManager.is_powered:
		var energy_ratio: float
		if PowerManager.is_powered:
			energy_ratio = PowerManager.time_remaining / PowerManager.get_current_max_duration()
		else:
			var max_progress: float = float(PowerManager.current_tier + 1) / 3.0
			energy_ratio = _progress / max_progress
		var current_speed: float = WHEEL_ROTATION_SPEED * (1.0 + energy_ratio * -15.0)
		_back_sprite.rotation += current_speed * delta
		_wheel_sprite.rotation += current_speed * delta
		
func _start_wheel_mode() -> void:
	_is_active = true
	var current_ratio: float = 0.0
	if PowerManager.is_powered:
		current_ratio = PowerManager.time_remaining / PowerManager.get_current_max_duration()
	_progress = current_ratio * float(PowerManager.current_tier + 1) / 3.0
	_last_direction = 0
	var max_progress: float = float(PowerManager.current_tier + 1) / 3.0
	var notes_for_tier: int = max(int(note_sounds.size() * (float(PowerManager.current_tier + 1) / 3.0)), 1)
	var dynamic_step: float = max_progress / float(notes_for_tier)
	_next_note_index = int(_progress / dynamic_step)
	_player_ref = get_tree().get_first_node_in_group("player") as CharacterBody2D
	_player_ref.is_in_wheel_mode = true
	_player_ref.global_position = global_position + player_wheel_offset
	_player_ref.sprite.play("run")
	_player_ref.sprite.speed_scale = ANIM_FPS_MIN / _player_ref.sprite.sprite_frames.get_animation_speed("run")
	_key_hints.visible = true
	_key_left._timer = 0.0
	_key_right._timer = 0.25
	EventBus.interaction_unavailable.emit()
	EventBus.wheel_started.emit()
	EventBus.wheel_progress_changed.emit(_progress)
	_player_ref.z_index = 1
	_player_ref.sprite.flip_h = true
	_player_ref.rotation = PLAYER_WHEEL_ROTATION
	
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
		var max_progress: float = float(PowerManager.current_tier + 1) / 3.0
		_progress = clampf(_progress + PROGRESS_PER_ALTERNATION, 0.0, max_progress)
		EventBus.wheel_progress_changed.emit(_progress)
		_check_note_threshold(previous_progress)
		_update_wheel_anim()
		if _progress >= max_progress:
			_complete_wheel()
			return

	_last_direction = direction

func _check_note_threshold(previous_progress: float) -> void:
	var max_progress: float = float(PowerManager.current_tier + 1) / 3.0
	var notes_for_tier: int = int(note_sounds.size() * (float(PowerManager.current_tier + 1) / 3.0))
	notes_for_tier = max(notes_for_tier, 1)
	var dynamic_step: float = max_progress / float(notes_for_tier)
	var next_threshold: float = _next_note_index * dynamic_step + dynamic_step

	if _progress >= next_threshold and previous_progress < next_threshold:
		if _next_note_index < notes_for_tier:
			AudioManager.play_sfx(note_sounds[_next_note_index])
			_next_note_index += 1

func _apply_decay(delta: float) -> void:
	if _progress <= 0.0:
		return
	_progress = max(_progress - DECAY_PER_SECOND * delta, 0.0)
	EventBus.wheel_progress_changed.emit(_progress)
	_update_wheel_anim()
	
func _complete_wheel() -> void:
	_is_active = false
	_is_on_cooldown = true
	_key_hints.visible = false
	_player_ref.sprite.stop()
	_player_ref.sprite.speed_scale = 1.0
	PowerManager.recharge()
	EventBus.wheel_completed.emit()
	AudioManager.play_sfx(success_sound)
	await get_tree().create_timer(EXIT_DELAY).timeout
	_player_ref.z_index = 3
	_player_ref.is_in_wheel_mode = false
	_player_ref.rotation = 0.0
	await get_tree().create_timer(POST_COMPLETION_COOLDOWN - EXIT_DELAY).timeout
	_is_on_cooldown = false
	if player_in_range:
		EventBus.interaction_available.emit("Press E to spin the wheel")

func _update_wheel_anim() -> void:
	var base_fps: float = _player_ref.sprite.sprite_frames.get_animation_speed("run")
	var t: float = _progress / (float(PowerManager.current_tier + 1) / 3.0)
	var target_fps: float = lerpf(ANIM_FPS_MIN, ANIM_FPS_MAX, t)
	_player_ref.sprite.speed_scale = target_fps / base_fps
