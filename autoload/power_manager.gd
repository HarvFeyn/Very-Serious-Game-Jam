extends Node

const BATTERY_DOWN_SOUND: AudioStream = preload("res://audio/SFX/BatteryDown.mp3")

enum PowerTier {
	TIER_1,
	TIER_2,
	TIER_3,
}

const TIER_DURATIONS: Dictionary = {
	PowerTier.TIER_1: 45.0,
	PowerTier.TIER_2: 80.0,
	PowerTier.TIER_3: 120.0,
}

const LIT_COLOR: Color = GameColors.LIT_COLOR
const WARNING_COLOR: Color = GameColors.WARNING_COLOR
const CRITICAL_COLOR: Color = GameColors.CRITICAL_COLOR
const DEPLETED_COLOR: Color = GameColors.DEPLETED_COLOR

const WARNING_THRESHOLD: float = 30.0
const CRITICAL_THRESHOLD: float = 20.0
const STEP_TWEEN_DURATION: float = 0.5
const WHEEL_EXIT_DURATION: float = 1.0

var energy_per_alternation: float = 1
var _wheel_is_active: bool = false

enum LightLevel {
	FULL,
	WARNING,
	CRITICAL,
	DEPLETED,
}

var current_tier: PowerTier = PowerTier.TIER_1
var time_remaining: float = 0.0
var is_powered: bool = false
var _current_light_level: LightLevel = LightLevel.DEPLETED
var _current_color: Color = DEPLETED_COLOR
var _depletion_timer: float = 0.0
var _step_tween: Tween

func _ready() -> void:
	EventBus.game_reset.connect(full_reset)
	EventBus.wheel_started.connect(_on_wheel_started)
	EventBus.wheel_completed.connect(_on_wheel_finished)
	
func get_current_max_duration() -> float:
	return TIER_DURATIONS[current_tier]

func get_energy_ratio() -> float:
	if not is_powered:
		return 0.0
	return time_remaining / get_current_max_duration()

func get_max_energy_for_tier() -> float:
	return get_current_max_duration()

func is_tier_full() -> bool:
	print("depletion_timer: ", _depletion_timer, " max: ", get_max_energy_for_tier())
	return _depletion_timer >= get_max_energy_for_tier()

func add_energy(amount: float) -> void:
	if not is_powered:
		is_powered = true

	_depletion_timer = minf(_depletion_timer + amount, get_max_energy_for_tier())
	time_remaining = _depletion_timer
	EventBus.power_level_changed.emit(get_energy_ratio())

func advance_tier() -> void:
	if current_tier < PowerTier.TIER_3:
		current_tier += 1
		EventBus.tier_advanced.emit(current_tier)
		match current_tier:
			PowerTier.TIER_2:
				if _current_light_level != LightLevel.CRITICAL and _current_light_level != LightLevel.DEPLETED:
					AudioManager.set_music_state(MusicEnums.MusicState.ROOM2)
			PowerTier.TIER_3:
				if _current_light_level != LightLevel.CRITICAL and _current_light_level != LightLevel.DEPLETED:
					AudioManager.set_music_state(MusicEnums.MusicState.ROOM3)
					
func _on_wheel_started() -> void:
	_wheel_is_active = true
	
func _on_wheel_finished() -> void:
	_wheel_is_active = false
	_set_light_level(LightLevel.FULL, WHEEL_EXIT_DURATION)
	EventBus.power_recharged.emit()
	EventBus.alarm_deactivated.emit()
	_handle_music_on_recharge()
	
func _handle_music_on_recharge() -> void:
	match current_tier:
		PowerTier.TIER_1:
			if AudioManager.music_playing != MusicEnums.MusicState.ROOM1:
				AudioManager.set_music_state(MusicEnums.MusicState.ROOM1)
		PowerTier.TIER_2:
			if AudioManager.music_playing != MusicEnums.MusicState.ROOM2:
				AudioManager.set_music_state(MusicEnums.MusicState.ROOM2)
		PowerTier.TIER_3:
			if AudioManager.music_playing != MusicEnums.MusicState.ROOM3:
				AudioManager.set_music_state(MusicEnums.MusicState.ROOM3)

func _process(delta: float) -> void:
	if not is_powered:
		return

	_depletion_timer -= delta
	time_remaining = max(_depletion_timer, 0.0)

	if _depletion_timer <= 0.0:
		_on_power_depleted()
		return

	EventBus.power_level_changed.emit(time_remaining / get_current_max_duration())
	
	if not _wheel_is_active:
		_update_light_level_for_time(_depletion_timer)

func _update_light_level_for_time(remaining: float) -> void:
	var target_level: LightLevel
	if remaining > WARNING_THRESHOLD:
		target_level = LightLevel.FULL
	elif remaining > CRITICAL_THRESHOLD:
		target_level = LightLevel.WARNING
	else:
		target_level = LightLevel.CRITICAL

	if target_level != _current_light_level:
		_set_light_level(target_level)

func _set_light_level(level: LightLevel, duration: float = STEP_TWEEN_DURATION) -> void:
	_current_light_level = level

	var target_color: Color
	match level:
		LightLevel.FULL:
			target_color = LIT_COLOR
			EventBus.alarm_deactivated.emit()
		LightLevel.WARNING:
			target_color = WARNING_COLOR
			AudioManager.play_sfx(BATTERY_DOWN_SOUND)
		LightLevel.CRITICAL:
			target_color = CRITICAL_COLOR
			EventBus.alarm_activated.emit()
			AudioManager.play_sfx(BATTERY_DOWN_SOUND)
			if AudioManager.music_playing != MusicEnums.MusicState.STRESS:
				AudioManager.set_music_state(MusicEnums.MusicState.STRESS)
		LightLevel.DEPLETED:
			target_color = DEPLETED_COLOR
			EventBus.alarm_activated.emit()
			AudioManager.play_sfx(BATTERY_DOWN_SOUND)

	if _step_tween:
		_step_tween.kill()
	_step_tween = create_tween()
	_step_tween.tween_method(_apply_color, _current_color, target_color, duration)

func _apply_color(color: Color) -> void:
	_current_color = color
	EventBus.power_color_changed.emit(color)

func _on_power_depleted() -> void:
	is_powered = false
	_set_light_level(LightLevel.DEPLETED)
	EventBus.power_depleted.emit()

func full_reset() -> void:
	if _step_tween:
		_step_tween.kill()
	current_tier = PowerTier.TIER_1
	time_remaining = 0.0
	_depletion_timer = 0.0
	is_powered = false
	_current_light_level = LightLevel.DEPLETED
	_current_color = DEPLETED_COLOR
	if AudioManager.music_playing != MusicEnums.MusicState.STRESS:
		AudioManager.set_music_state(MusicEnums.MusicState.STRESS)
