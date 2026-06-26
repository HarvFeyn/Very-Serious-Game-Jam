extends StaticBody2D

const DOOR_OPEN_OFFSET: float = 60.0
const DOOR_OPEN_DURATION: float = 0.4
const SPAWN_OFFSET_X: float = 150.0
const WALK_IN_OFFSET_X: int = 250
const SCRATCH_REQUIRED: int = 20
const SCRATCH_IDLE_TIMEOUT: float = 0.7

@export var target_door: NodePath
@export var puzzle_solved: bool = false
@export var is_arrival_door: bool = false
@export var advances_tier: bool = false
@export var reverse_door: bool = false
@export var open_door_sound: AudioStream = preload("res://entities/environement/door/OpenDoor.mp3")
@export var deny_sound: AudioStream = preload("res://entities/environement/door/Deny.mp3")
@export var scratch_loop_sound: AudioStream = preload("res://entities/environement/door/GrattePorteV2.mp3")
@export var door_puzzle_solved: AudioStream = preload("res://entities/environement/door/UnlockDoor.mp3")
@export var quest_index: int = -1

var is_locked: bool = true
var player_in_range: bool = false
var _is_scratching: bool = false
var _scratch_count: int = 0
var _last_scratch_direction: int = 0
var _player_ref: CharacterBody2D = null
var _idle_timer: float = 0.0
var _scratch_sound_player: AudioStreamPlayer = null


@onready var _door1: Sprite2D = $Door1
@onready var _door2: Sprite2D = $Door2
@onready var _key_hints: Node2D = $KeyHints
@onready var _key_up: Node2D = $KeyHints/KeyUp
@onready var _key_down: Node2D = $KeyHints/KeyDown

var _door1_closed_pos: Vector2
var _door2_closed_pos: Vector2

func _ready() -> void:
	$InteractionArea.body_entered.connect(_on_interaction_area_entered)
	$InteractionArea.body_exited.connect(_on_interaction_area_exited)
	$CrossingArea.body_entered.connect(_on_crossing_area_entered)
	EventBus.game_reset.connect(_on_game_reset)
	_door1_closed_pos = _door1.position
	_door2_closed_pos = _door2.position
	_key_hints.visible = false
	if is_arrival_door:
		unlock(false)

func get_spawn_position() -> Vector2:
	return global_position + Vector2(SPAWN_OFFSET_X * (-1 if reverse_door else 1), 0)

func get_offset() -> Vector2:
	return Vector2(WALK_IN_OFFSET_X * (-1 if reverse_door else 1),0)

func open_from_arrival() -> void:
	if is_locked:
		unlock(true)

func _on_interaction_area_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	player_in_range = true
	_player_ref = body as CharacterBody2D
	if is_locked:
		EventBus.interaction_available.emit("Press E to interact")

func _on_interaction_area_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	player_in_range = false
	if is_locked:
		_cancel_scratch()
		EventBus.interaction_unavailable.emit()

func _on_crossing_area_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_locked:
		var player_body: CharacterBody2D = body as CharacterBody2D
		_trigger_transition(player_body)

func _process(delta: float) -> void:
	if player_in_range and is_locked and not _is_scratching \
			and Input.is_action_just_pressed("interact"):
		_start_scratch()
		return

	if _is_scratching:
		_handle_scratch_input()
		_update_idle_timer(delta)

func _start_scratch() -> void:
	_is_scratching = true
	_scratch_count = 0
	_last_scratch_direction = 0
	_idle_timer = 0.0
	_player_ref.controls_enabled = false
	_player_ref.velocity = Vector2.ZERO
	_player_ref.sprite.play("gratte")
	_key_hints.visible = true
	_key_up._timer = 0.0
	_key_down._timer = 0.25
	EventBus.interaction_unavailable.emit()

func _handle_scratch_input() -> void:
	var direction: int = 0
	if Input.is_action_just_pressed("move_up"):
		direction = 1
	elif Input.is_action_just_pressed("move_down"):
		direction = -1

	if direction == 0:
		return

	if _scratch_sound_player == null:
		_start_scratch_sound()

	_idle_timer = 0.0

	if _last_scratch_direction != 0 and direction != _last_scratch_direction:
		_scratch_count += 1
		if _scratch_count >= SCRATCH_REQUIRED:
			_complete_scratch()
			return

	_last_scratch_direction = direction

func _update_idle_timer(delta: float) -> void:
	if _scratch_sound_player == null:
		return
	_idle_timer += delta
	if _idle_timer >= SCRATCH_IDLE_TIMEOUT:
		_stop_scratch_sound()

func _start_scratch_sound() -> void:
	if scratch_loop_sound == null:
		return
	_scratch_sound_player = AudioStreamPlayer.new()
	_scratch_sound_player.bus = AudioManager.BUS_SFX
	_scratch_sound_player.stream = scratch_loop_sound
	_scratch_sound_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_scratch_sound_player)
	_scratch_sound_player.play()

func _stop_scratch_sound() -> void:
	if _scratch_sound_player == null:
		return
	var player: AudioStreamPlayer = _scratch_sound_player
	_scratch_sound_player = null
	var tween: Tween = create_tween()
	tween.tween_property(player, "volume_db", -80.0, 0.5)
	tween.finished.connect(player.queue_free)

func _complete_scratch() -> void:
	_stop_scratch_sound()
	_cancel_scratch()
	if puzzle_solved:
		unlock(true)
	else:
		AudioManager.play_sfx(deny_sound, 10.0)
		if _player_ref != null:
			EventBus.interaction_available.emit("Press E to interact")

func _cancel_scratch() -> void:
	_is_scratching = false
	_scratch_count = 0
	_last_scratch_direction = 0
	_idle_timer = 0.0
	_stop_scratch_sound()
	_key_hints.visible = false
	if _player_ref != null:
		_player_ref.controls_enabled = true

func unlock(play_sound: bool) -> void:
	is_locked = false
	$CollisionShape2D.set_deferred("disabled", true)
	EventBus.interaction_unavailable.emit()
	EventBus.door_unlocked.emit(self)
	if advances_tier:
		PowerManager.advance_tier()
	_animate_doors_open()
	if play_sound and open_door_sound:
		AudioManager.play_sfx(open_door_sound, 10.0)
	if quest_index >= 0:
		EventBus.quest_discovered.emit(quest_index)

func _animate_doors_open() -> void:
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(_door1, "position", _door1_closed_pos + Vector2(DOOR_OPEN_OFFSET, 0), DOOR_OPEN_DURATION)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(_door2, "position", _door2_closed_pos + Vector2(-DOOR_OPEN_OFFSET, 0), DOOR_OPEN_DURATION)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _animate_doors_close() -> void:
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(_door1, "position", _door1_closed_pos, DOOR_OPEN_DURATION)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(_door2, "position", _door2_closed_pos, DOOR_OPEN_DURATION)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _on_game_reset() -> void:
	if is_arrival_door:
		return
	puzzle_solved = false
	_cancel_scratch()
	is_locked = true
	$CollisionShape2D.set_deferred("disabled", false)
	_animate_doors_close()

func _trigger_transition(player_body: CharacterBody2D) -> void:
	var door: StaticBody2D = get_node(target_door) as StaticBody2D
	var target_level: GameLevel = door.get_parent() as GameLevel
	door.open_from_arrival()
	LevelManager.go_to_level_with_walk_in(
		player_body,
		target_level,
		door.get_spawn_position(),
		get_offset()
	)

func solve_puzzle() -> void:
	AudioManager.play_sfx(door_puzzle_solved, 5.0)
	puzzle_solved = true
	EventBus.door_unlocked.emit(self)
