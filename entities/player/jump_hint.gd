extends Sprite2D

@export var texture_released: Texture2D
@export var texture_pressed: Texture2D

const PRESS_INTERVAL: float = 0.5

var _timer: float = 0.0
var _is_pressed: bool = false

func _ready() -> void:
	texture = texture_released
	visible = false
	EventBus.jump_hint_requested.connect(_on_jump_hint_requested)
	EventBus.jump_hint_dismissed.connect(_on_jump_hint_dismissed)

func _on_jump_hint_requested() -> void:
	visible = true
	_timer = 0.0
	_is_pressed = false

func _on_jump_hint_dismissed() -> void:
	visible = false

func _process(delta: float) -> void:
	if not visible:
		return
	_timer += delta
	if _timer >= PRESS_INTERVAL:
		_timer = 0.0
		_is_pressed = !_is_pressed
		texture = texture_pressed if _is_pressed else texture_released
