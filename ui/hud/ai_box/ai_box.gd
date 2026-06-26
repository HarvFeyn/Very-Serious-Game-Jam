extends Control

@export var char_reveal_speed: float = 0.02
@export var display_duration: float = 2.5
@export var fade_duration: float = 0.4
@export var weird_voice1: AudioStream = preload("res://ui/hud/ai_box/Voix1.mp3")
@export var weird_voice2: AudioStream = preload("res://ui/hud/ai_box/Voix2.mp3")
@export var weird_voice3: AudioStream = preload("res://ui/hud/ai_box/Voix3.mp3")

@onready var label: RichTextLabel = $Panel/Label

var _current_tween: Tween
var _voice_player: AudioStreamPlayer = null
var _message_queue: Array[String] = []
var _is_displaying: bool = false

func _ready() -> void:
	visible = false
	modulate.a = 0.0
	EventBus.ai_message.connect(_on_ai_message)

func _on_ai_message(text: String) -> void:
	_message_queue.append(text)
	if not _is_displaying:
		_display_next()

func _display_next() -> void:
	if _message_queue.is_empty():
		_is_displaying = false
		return

	_is_displaying = true
	var text: String = _message_queue.pop_front()

	_stop_voice()
	_play_random_voice()

	label.text = text
	label.visible_characters = 0
	visible = true
	modulate.a = 1.0

	var type_duration: float = text.length() * char_reveal_speed
	_current_tween = create_tween()
	_current_tween.tween_property(label, "visible_characters", text.length(), type_duration)
	_current_tween.tween_interval(display_duration)
	_current_tween.tween_callback(_stop_voice)
	_current_tween.tween_property(self, "modulate:a", 0.0, fade_duration)
	_current_tween.tween_callback(_on_display_finished)

func _on_display_finished() -> void:
	visible = false
	_is_displaying = false
	_display_next()

func _play_random_voice() -> void:
	var voices: Array[AudioStream] = [weird_voice1, weird_voice2, weird_voice3]
	voices = voices.filter(func(v: AudioStream) -> bool: return v != null)
	if voices.is_empty():
		return
	var chosen: AudioStream = voices[randi() % voices.size()]
	_voice_player = AudioStreamPlayer.new()
	_voice_player.bus = AudioManager.BUS_SFX
	_voice_player.stream = chosen
	_voice_player.volume_db = -3.0
	add_child(_voice_player)
	_voice_player.play()

func _stop_voice() -> void:
	if _voice_player == null:
		return
	var player: AudioStreamPlayer = _voice_player
	_voice_player = null
	var tween: Tween = create_tween()
	tween.tween_property(player, "volume_db", -80.0, 0.3)
	tween.finished.connect(player.queue_free)

func dismiss() -> void:
	if _current_tween and _current_tween.is_valid():
		_current_tween.kill()
	_stop_voice()
	_message_queue.clear()
	_is_displaying = false
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_duration)
	tween.tween_callback(func() -> void: visible = false)
	
