extends Sprite2D

@export var texture_released: Texture2D
@export var texture_pressed: Texture2D

const PRESS_INTERVAL: float = 0.5

var _timer: float = 0.0
var _is_pressed: bool = false

func _ready() -> void:
	texture = texture_released
	visible = false
	EventBus.interaction_available.connect(_on_interaction_available)
	EventBus.interaction_unavailable.connect(_on_interaction_unavailable)

func _on_interaction_available(_text: String) -> void:
	visible = true
	_timer = 0.0
	_is_pressed = false
	texture = texture_released

func _on_interaction_unavailable() -> void:
	visible = false

func _process(delta: float) -> void:
	if not visible:
		return
	_timer += delta
	if _timer >= PRESS_INTERVAL:
		_timer = 0.0
		_is_pressed = !_is_pressed
		texture = texture_pressed if _is_pressed else texture_released
