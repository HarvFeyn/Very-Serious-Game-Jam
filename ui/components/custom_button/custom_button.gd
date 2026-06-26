class_name CustomButton
extends Button

@export var click_sound: AudioStream = preload("res://audio/SFX/Clavier3.mp3")
@export var hover_sound: AudioStream
@export var enable_tween: bool = true

const SCALE_HOVER: Vector2 = Vector2(1.05, 1.05)
const SCALE_PRESS: Vector2 = Vector2(0.95, 0.95)
const SCALE_NORMAL: Vector2 = Vector2(1.0, 1.0)
const TWEEN_DURATION: float = 0.08
const ROTATION_HOVER: float = 1.5
const ROTATION_NORMAL: float = 0.0


func _ready() -> void:
	_update_pivot()
	resized.connect(_update_pivot)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)


func _update_pivot() -> void:
	pivot_offset = size / 2.0


func _on_mouse_entered() -> void:
	AudioManager.play_sfx(hover_sound)
	if enable_tween:
		_scale_to(SCALE_HOVER)
		_rotate_to(ROTATION_HOVER)


func _on_mouse_exited() -> void:
	if enable_tween:
		_scale_to(SCALE_NORMAL)
		_rotate_to(ROTATION_NORMAL)


func _on_button_down() -> void:
	AudioManager.play_sfx(click_sound,-10.0)
	if enable_tween:
		_scale_to(SCALE_PRESS)
		_rotate_to(ROTATION_NORMAL)


func _on_button_up() -> void:
	if enable_tween:
		_scale_to(SCALE_HOVER if is_hovered() else SCALE_NORMAL)
		_rotate_to(ROTATION_HOVER if is_hovered() else ROTATION_NORMAL)


func _scale_to(target_scale: Vector2) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", target_scale, TWEEN_DURATION) \
		.set_trans(Tween.TRANS_BACK) \
		.set_ease(Tween.EASE_OUT)


func _rotate_to(target_degrees: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "rotation_degrees", target_degrees, TWEEN_DURATION) \
		.set_trans(Tween.TRANS_BACK) \
		.set_ease(Tween.EASE_OUT)
