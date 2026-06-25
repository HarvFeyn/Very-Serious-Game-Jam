extends Node2D

@export var fill_speed: float = 0.3
@export var drink_sound: AudioStream
@export var _volume_drink: int = 10
@export var player_lock_position: Vector2

var _player_in_range: bool = false
var _player_ref: CharacterBody2D = null
var _is_drinking: bool = false
var _drink_sound_player: AudioStreamPlayer = null


func _ready() -> void:
	$InteractionArea.body_entered.connect(_on_body_entered)
	$InteractionArea.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = true
		_player_ref = body as CharacterBody2D
		if Globals.pee_level < 1.0:
			EventBus.interaction_available.emit("Hold E to drink")

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
		_stop_drinking()
		EventBus.interaction_unavailable.emit()

func _process(delta: float) -> void:
	if not _player_in_range or Globals.pee_level >= 1.0:
		return

	if Input.is_action_pressed("interact"):
		if not _is_drinking:
			_start_drinking()
		_fill(delta)
	else:
		if _is_drinking:
			_stop_drinking()

func _start_drinking() -> void:
	_is_drinking = true
	_player_ref.controls_enabled = false
	_player_ref.velocity = Vector2.ZERO
	_player_ref.global_position = global_position + player_lock_position
	_player_ref.sprite.flip_h = false
	_player_ref.sprite.play("push")
	if drink_sound and _drink_sound_player == null:
		_drink_sound_player = AudioStreamPlayer.new()
		_drink_sound_player.bus = AudioManager.BUS_SFX
		_drink_sound_player.stream = drink_sound
		_drink_sound_player.volume_db = _volume_drink
		_drink_sound_player.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(_drink_sound_player)
		_drink_sound_player.play()

func _stop_drinking() -> void:
	_is_drinking = false
	if _player_ref != null:
		_player_ref.controls_enabled = true
		_player_ref.sprite.play("idle")
	if _drink_sound_player != null:
		var player: AudioStreamPlayer = _drink_sound_player
		_drink_sound_player = null
		var tween: Tween = create_tween()
		tween.tween_property(player, "volume_db", -80.0, 0.3)
		tween.finished.connect(player.queue_free)

func _fill(delta: float) -> void:
	Globals.pee_level = minf(Globals.pee_level + fill_speed * delta, 1.0)
	EventBus.pee_changed.emit(Globals.pee_level)
	if Globals.pee_level >= 1.0:
		_stop_drinking()
		EventBus.pee_full.emit()
		EventBus.interaction_unavailable.emit()
