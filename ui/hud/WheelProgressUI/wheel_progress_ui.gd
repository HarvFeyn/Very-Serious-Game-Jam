extends Control

const COLOR_BAR_1: Color = Color(0.808, 0.597, 0.0, 1.0)
const COLOR_BAR_2: Color = Color(0.725, 0.813, 0.025, 1.0)
const COLOR_BAR_3: Color = Color(0.1, 0.9, 0.2)
const COLOR_LOCKED: Color = Color(0.126, 0.126, 0.126, 0.953)

@onready var _bar1: ProgressBar = $Bar1
@onready var _bar2: ProgressBar = $Bar2
@onready var _bar3: ProgressBar = $Bar3

var _active_bars: int = 1

func _ready() -> void:
	visible = true
	EventBus.wheel_progress_changed.connect(_on_progress_changed)
	EventBus.tier_advanced.connect(_on_tier_advanced)
	EventBus.power_level_changed.connect(_on_power_level_changed)
	EventBus.power_depleted.connect(_on_power_depleted)
	EventBus.game_reset.connect(_on_game_reset)

	_active_bars = PowerManager.current_tier + 1
	_update_bar_colors()
	_update_bars(0.0)

func _on_power_level_changed(ratio: float) -> void:
	var scaled_progress: float = ratio * float(_active_bars) / 3.0
	_update_bars(scaled_progress)

func _on_power_depleted() -> void:
	_update_bars(0.0)

func _on_game_reset() -> void:
	_update_bars(0.0)

func _on_progress_changed(progress: float) -> void:
	_update_bars(progress)

func _on_tier_advanced(tier: int) -> void:
	_active_bars = tier + 1
	_update_bar_colors()

func _update_bar_colors() -> void:
	_bar1.add_theme_stylebox_override("fill", _make_stylebox(COLOR_BAR_1 if _active_bars >= 1 else COLOR_LOCKED))
	_bar2.add_theme_stylebox_override("fill", _make_stylebox(COLOR_BAR_2 if _active_bars >= 2 else COLOR_LOCKED))
	_bar3.add_theme_stylebox_override("fill", _make_stylebox(COLOR_BAR_3 if _active_bars >= 3 else COLOR_LOCKED))

func _make_stylebox(color: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = color
	return style

func _update_bars(progress: float) -> void:
	var max_progress: float = float(_active_bars) / 3.0

	var clamped: float = minf(progress, max_progress)

	_bar1.value = clampf((clamped / (1.0 / 3.0)), 0.0, 1.0) * 100.0
	_bar2.value = clampf(((clamped - 1.0 / 3.0) / (1.0 / 3.0)), 0.0, 1.0) * 100.0
	_bar3.value = clampf(((clamped - 2.0 / 3.0) / (1.0 / 3.0)), 0.0, 1.0) * 100.0
