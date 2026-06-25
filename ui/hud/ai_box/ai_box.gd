extends Control


@export var char_reveal_speed: float = 0.03   ## secondes par caractère
@export var display_duration: float = 2.5     ## temps affiché une fois le texte complet (0 = reste affiché)
@export var fade_duration: float = 0.4

@onready var label: RichTextLabel = $Panel/Label

var _current_tween: Tween


func _ready() -> void:
	print("AIBox actif")
	visible = false
	modulate.a = 0.0
	EventBus.ai_message.connect(_on_ai_message)


func _on_ai_message(text: String) -> void:
	if _current_tween and _current_tween.is_valid():
		_current_tween.kill()

	label.text = text
	label.visible_characters = 0
	visible = true
	modulate.a = 1.0

	var type_duration: float = text.length() * char_reveal_speed

	_current_tween = create_tween()
	_current_tween.tween_property(label, "visible_characters", text.length(), type_duration)

	if display_duration > 0.0:
		_current_tween.tween_interval(display_duration)
		_current_tween.tween_property(self, "modulate:a", 0.0, fade_duration)
		_current_tween.tween_callback(func() -> void: visible = false)



func dismiss() -> void:
	if _current_tween and _current_tween.is_valid():
		_current_tween.kill()
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_duration)
	tween.tween_callback(func() -> void: visible = false)
