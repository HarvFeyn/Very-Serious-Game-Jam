extends Control

@onready var _bar: ProgressBar = $ProgressBar

const COLOR_BLUE: Color = Color(0.454, 0.81, 0.97, 1.0)
const COLOR_YELLOW: Color = Color(1.0, 0.884, 0.408, 1.0)

var _tween: Tween
var _is_draining: bool = false

func _ready() -> void:
	_bar.value = 0
	modulate.a = 0.0
	_set_bar_color(COLOR_BLUE)
	EventBus.pee_changed.connect(_on_pee_changed)
	EventBus.pee_full.connect(_on_pee_full)
	EventBus.litter_used.connect(_on_litter_used)
	EventBus.game_reset.connect(_on_game_reset)

func _on_pee_changed(value: float) -> void:
	_bar.value = value * 100.0
	if value > 0.0 and modulate.a == 0.0 and not _is_draining:
		_fade(1.0)
	elif value <= 0.0 and _is_draining:
		_is_draining = false
		_fade(0.0)

func _on_pee_full() -> void:
	await get_tree().create_timer(2.0).timeout
	_fade(0.0)

func _on_game_reset() -> void:
	_bar.value = 0
	_is_draining = false
	_set_bar_color(COLOR_BLUE)
	_fade(0.0)

func _fade(target_alpha: float) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", target_alpha, 0.5)

func _set_bar_color(color: Color) -> void:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = color
	_bar.add_theme_stylebox_override("fill", style)

func _on_litter_used() -> void:
	_set_bar_color(COLOR_YELLOW)
	_fade(1.0)
	_is_draining = true
