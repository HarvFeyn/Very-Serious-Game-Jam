extends Node2D
class_name CatEngine

@export var target_door: NodePath
@export var overheat_sound: AudioStream
@export var running_sound: AudioStream

var _fuel_inserted: bool = false
var _valve_turned: bool = false
var _sound_player: AudioStreamPlayer = null
var _shake_tween: Tween
var _initial_engine_position: Vector2

func _ready() -> void:
	EventBus.game_reset.connect(_on_game_reset)
	_initial_engine_position = position

func on_fuel_inserted() -> void:
	_fuel_inserted = true
	_update_engine_sound()
	if not _valve_turned:
		_start_shake()
	_check_puzzle()

func on_valve_turned() -> void:
	_valve_turned = true
	_stop_shake()
	_update_engine_sound()
	_check_puzzle()

func _start_shake() -> void:
	if _shake_tween:
		_shake_tween.kill()
	_shake_tween = create_tween().set_loops()
	_shake_tween.tween_method(_apply_shake, 0.0, 1.0, 0.05)

func _stop_shake() -> void:
	if _shake_tween:
		_shake_tween.kill()
		_shake_tween = null
	position = _initial_engine_position

func _apply_shake(_t: float) -> void:
	var intensity: float = 1.3
	position = _initial_engine_position + Vector2(
		randf_range(-intensity, intensity),
		randf_range(-intensity, intensity)
	)
			
func _update_engine_sound() -> void:
	if not _fuel_inserted:
		return
	_stop_sound()
	var sound: AudioStream = overheat_sound if not _valve_turned else running_sound
	if sound:
		_sound_player = AudioStreamPlayer.new()
		_sound_player.bus = AudioManager.BUS_SFX
		_sound_player.stream = sound
		if sound != overheat_sound:
			_sound_player.volume_db = 10.0
		_sound_player.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(_sound_player)
		_sound_player.play()

func _stop_sound() -> void:
	if _sound_player != null:
		_sound_player.stop()
		_sound_player.queue_free()
		_sound_player = null

func _check_puzzle() -> void:
	if _fuel_inserted and _valve_turned:
		var door: StaticBody2D = get_node(target_door) as StaticBody2D
		door.solve_puzzle()

func _on_game_reset() -> void:
	_fuel_inserted = false
	_valve_turned = false
	_stop_sound()
	_stop_shake()
