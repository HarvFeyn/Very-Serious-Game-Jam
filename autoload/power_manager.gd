extends Node

const BATTERY_DOWN_SOUND: AudioStream = preload("res://audio/SFX/BatteryDown.mp3")

enum PowerTier {
	TIER_1,
	TIER_2,
	TIER_3,
	TIER_4,
}

const TIER_DURATIONS: Dictionary = {
	PowerTier.TIER_1: 40.0,
	PowerTier.TIER_2: 80.0,
	PowerTier.TIER_3: 120.0,
	PowerTier.TIER_4: 160.0,
}

const LIT_COLOR: Color = GameColors.LIT_COLOR
const WARNING_COLOR: Color = GameColors.WARNING_COLOR
const CRITICAL_COLOR: Color = GameColors.CRITICAL_COLOR
const DEPLETED_COLOR: Color = GameColors.DEPLETED_COLOR

const WARNING_THRESHOLD: float = 30.0
const CRITICAL_THRESHOLD: float = 20.0
const STEP_TWEEN_DURATION: float = 0.5
const WHEEL_EXIT_DURATION: float = 1.0

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

func get_current_max_duration() -> float:
	return TIER_DURATIONS[current_tier]

func advance_tier() -> void:
	if current_tier < PowerTier.TIER_4:
		current_tier += 1
		EventBus.tier_advanced.emit(current_tier)
		match current_tier:
			PowerTier.TIER_2:
				if _current_light_level != LightLevel.CRITICAL and _current_light_level != LightLevel.DEPLETED:
					AudioManager.set_music_state(MusicEnums.MusicState.ROOM2)
			PowerTier.TIER_3:
				if _current_light_level != LightLevel.CRITICAL and _current_light_level != LightLevel.DEPLETED:
					AudioManager.set_music_state(MusicEnums.MusicState.ROOM3)

func recharge() -> void:
	var max_duration: float = get_current_max_duration()
	time_remaining = max_duration
	_depletion_timer = max_duration
	is_powered = true

	var previous_light_level: LightLevel = _current_light_level

	_set_light_level(LightLevel.FULL, WHEEL_EXIT_DURATION)
	EventBus.power_recharged.emit()
	EventBus.alarm_deactivated.emit()

	if previous_light_level == LightLevel.CRITICAL or previous_light_level == LightLevel.DEPLETED:
		match current_tier:
			PowerTier.TIER_1:
				AudioManager.set_music_state(MusicEnums.MusicState.ROOM1)
			PowerTier.TIER_2:
				AudioManager.set_music_state(MusicEnums.MusicState.ROOM2)
			PowerTier.TIER_3, PowerTier.TIER_4:
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
	print("full reset called")
	if _step_tween:
		_step_tween.kill()

	current_tier = PowerTier.TIER_1
	time_remaining = 0.0
	_depletion_timer = 0.0
	is_powered = false
	_current_light_level = LightLevel.FULL
	_current_color = LIT_COLOR
	AudioManager.set_music_state(MusicEnums.MusicState.ROOM1)
