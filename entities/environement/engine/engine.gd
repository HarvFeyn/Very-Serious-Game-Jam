extends Node2D
class_name CatEngine

@export var target_door: NodePath
@export var overheat_sound: AudioStream
@export var running_sound: AudioStream

@onready var _EnergyParticles: CPUParticles2D = $EnergyParticles

var fuel_inserted: bool = false
var _valve_turned: bool = false
var _shake_tween: Tween
var _initial_engine_position: Vector2
var _sound_player: AudioStreamPlayer2D = null

func _ready() -> void:
	EventBus.game_reset.connect(_on_game_reset)
	_initial_engine_position = position
	var parent_level: GameLevel = get_parent() as GameLevel
	EventBus.level_changed.connect(_on_level_changed.bind(parent_level))
	
func on_fuel_inserted() -> void:
	EventBus.quest_discovered.emit(4)
	fuel_inserted = true
	_update_engine_sound()
	if not _valve_turned:
		_start_shake()
	_check_puzzle()
	_EnergyParticles.emitting = true

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
	if not fuel_inserted:
		return
	_stop_sound()
	var sound: AudioStream = overheat_sound if not _valve_turned else running_sound
	if sound:
		_sound_player = AudioStreamPlayer2D.new()
		_sound_player.bus = AudioManager.BUS_SFX
		_sound_player.stream = sound
		_sound_player.process_mode = Node.PROCESS_MODE_ALWAYS
		_sound_player.max_distance = 1000.0
		_sound_player.attenuation = 1.5
		_sound_player.volume_db = 10.0
		add_child(_sound_player)
		_sound_player.play()

func _stop_sound() -> void:
	if _sound_player != null:
		_sound_player.stop()
		_sound_player.queue_free()
		_sound_player = null

func _check_puzzle() -> void:
	if fuel_inserted and _valve_turned:
		var door: StaticBody2D = get_node(target_door) as StaticBody2D
		door.solve_puzzle()

func _on_game_reset() -> void:
	fuel_inserted = false
	_valve_turned = false
	_stop_sound()
	_stop_shake()

func _on_level_changed(active_level: GameLevel, my_level: GameLevel) -> void:
	if _sound_player == null:
		return
	_sound_player.stream_paused = (active_level != my_level)
