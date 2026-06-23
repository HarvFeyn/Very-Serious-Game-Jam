extends Area2D

@export var return_point: Marker2D
@export var push_back_sound: AudioStream

const PUSHBACK_DURATION: float = 1.5

var _player_in_zone: bool = false
var _player_ref: CharacterBody2D = null
var _is_pushing_back: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	EventBus.power_depleted.connect(_on_power_depleted)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_zone = true
		_player_ref = body as CharacterBody2D
		EventBus.safe_zone_entered.emit()

func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if not PowerManager.is_powered and not _is_pushing_back:
		_push_player_back()
		return
	_player_in_zone = false
	_player_ref = null
	EventBus.safe_zone_exited.emit()

func _on_power_depleted() -> void:
	if not _player_in_zone:
		EventBus.game_reset.emit()

func _push_player_back() -> void:
	if _player_ref == null or return_point == null:
		return
	_is_pushing_back = true
	_player_ref.controls_enabled = false
	_player_ref.velocity = Vector2.ZERO

	if push_back_sound:
		AudioManager.play_sfx(push_back_sound)

	var tween: Tween = create_tween()
	tween.tween_property(_player_ref, "global_position", return_point.global_position, PUSHBACK_DURATION)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished

	_player_ref.controls_enabled = true
	_is_pushing_back = false
