extends Label

var _warning_triggered: bool = false
var _in_critical: bool = false

func _ready() -> void:
	EventBus.power_level_changed.connect(_on_power_level_changed)
	EventBus.power_depleted.connect(_on_power_depleted)
	EventBus.game_reset.connect(_on_game_reset)
	var max_seconds: int = int(PowerManager.get_current_max_duration())
	text = "00 / %d" % max_seconds

func _on_power_level_changed(_ratio: float) -> void:
	var seconds: int = int(ceil(PowerManager.time_remaining))
	var max_seconds: int = int(PowerManager.get_current_max_duration())
	text = "%d / %d" % [seconds, max_seconds]

	if not PowerManager.is_powered:
		return

	if PowerManager.time_remaining <= PowerManager.CRITICAL_THRESHOLD:
		add_theme_color_override("font_color", Color(1.0, 0.1, 0.1))
	elif PowerManager.time_remaining <= PowerManager.WARNING_THRESHOLD:
		add_theme_color_override("font_color", Color(1.0, 0.6, 0.0))
	else:
		add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))

func _on_power_depleted() -> void:
	var max_seconds: int = int(PowerManager.get_current_max_duration())
	text = "00 / %d" % max_seconds

func _on_game_reset() -> void:
	text = ""
	_warning_triggered = false
	_in_critical = false
	add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
