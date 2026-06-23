extends Control

@onready var _bar: ProgressBar = $ProgressBar

var _tween: Tween

func _ready() -> void:
	_bar.value = 0
	modulate.a = 0.0
	EventBus.pee_changed.connect(_on_pee_changed)
	EventBus.game_reset.connect(_on_game_reset)

func _on_pee_changed(value: float) -> void:
	_bar.value = value * 100.0

	if value > 0.0 and modulate.a == 0.0:
		_fade(1.0)
	elif value <= 0.0 and modulate.a > 0.0:
		_fade(0.0)

func _on_game_reset() -> void:
	_bar.value = 0
	_fade(0.0)

func _fade(target_alpha: float) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", target_alpha, 0.5)
