extends Node

const MAX_DURATION: float = 30.0
const DARK_COLOR: Color = Color(0.13, 0.13, 0.13, 1.0)
const LIT_COLOR: Color = Color(1.0, 1.0, 1.0)

var time_remaining: float = 0.0
var is_powered: bool = false

var _tween: Tween

func recharge() -> void:
	time_remaining = MAX_DURATION
	is_powered = true

	if _tween:
		_tween.kill()

	_tween = create_tween()
	_tween.tween_method(_update_light, LIT_COLOR, DARK_COLOR, MAX_DURATION)
	_tween.finished.connect(_on_power_depleted)

	EventBus.power_recharged.emit()

func _update_light(color: Color) -> void:
	EventBus.power_color_changed.emit(color)

func _on_power_depleted() -> void:
	is_powered = false
	EventBus.power_depleted.emit()
