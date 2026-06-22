extends Node

enum PowerTier {
	TIER_1,
	TIER_2,
	TIER_3,
	TIER_4,
}

const TIER_DURATIONS: Dictionary = {
	PowerTier.TIER_1: 80.0,
	PowerTier.TIER_2: 80.0,
	PowerTier.TIER_3: 120.0,
	PowerTier.TIER_4: 160.0,
}

const LIT_COLOR: Color = Color(1.0, 1.0, 1.0)
const WARNING_COLOR: Color = Color(0.75, 0.7, 0.65)
const CRITICAL_COLOR: Color = Color(0.45, 0.35, 0.35)
const DEPLETED_COLOR: Color = Color(0.1, 0.05, 0.05)

const WARNING_THRESHOLD: float = 40.0
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

func recharge() -> void:
	var max_duration: float = get_current_max_duration()
	time_remaining = max_duration
	_depletion_timer = max_duration
	is_powered = true

	_set_light_level(LightLevel.FULL, WHEEL_EXIT_DURATION)
	EventBus.power_recharged.emit()
	EventBus.alarm_deactivated.emit()

func _process(delta: float) -> void:
	if not is_powered:
		return

	_depletion_timer -= delta
	time_remaining = max(_depletion_timer, 0.0)

	if _depletion_timer <= 0.0:
		_on_power_depleted()
		return

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
		LightLevel.CRITICAL:
			target_color = CRITICAL_COLOR
			EventBus.alarm_activated.emit()
		LightLevel.DEPLETED:
			target_color = DEPLETED_COLOR
			EventBus.alarm_activated.emit()

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
	EventBus.game_reset.emit()

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
