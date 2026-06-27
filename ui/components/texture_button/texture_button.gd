class_name SettingsButton
extends Control

const ROTATION_DURATION: float = 0.4
const ROTATION_AMOUNT: float = 90.0
const COLOR_NORMAL: Color = Color(1.0, 1.0, 1.0, 1.0)
const COLOR_HOVER: Color = Color(1.5, 1.5, 1.5, 1.0)

@onready var _button: TextureButton = $TextureButton

func _ready() -> void:
	_button.pivot_offset = _button.size / 2.0
	_button.resized.connect(_update_pivot)
	_button.mouse_entered.connect(_on_mouse_entered)
	_button.mouse_exited.connect(_on_mouse_exited)

func _update_pivot() -> void:
	_button.pivot_offset = _button.size / 2.0

func _on_mouse_entered() -> void:
	_tween_rotation(_button.rotation_degrees + ROTATION_AMOUNT)
	_tween_color(COLOR_HOVER)

func _on_mouse_exited() -> void:
	_tween_color(COLOR_NORMAL)

func _tween_rotation(target: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(_button, "rotation_degrees", target, ROTATION_DURATION) \
		.set_trans(Tween.TRANS_CUBIC) \
		.set_ease(Tween.EASE_OUT)

func _tween_color(target: Color) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(_button, "modulate", target, 0.15) \
		.set_trans(Tween.TRANS_LINEAR)
