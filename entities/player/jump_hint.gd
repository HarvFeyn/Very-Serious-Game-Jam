extends Sprite2D

@export var texture_released: Texture2D
@export var texture_pressed: Texture2D
@export var texture_woaaw: Texture2D

const PRESS_INTERVAL: float = 0.5

var _timer: float = 0.0
var _frame_index: int = 0

func _ready() -> void:
	texture = texture_released
	visible = false
	EventBus.jump_hint_requested.connect(_on_jump_hint_requested)
	EventBus.jump_hint_dismissed.connect(_on_jump_hint_dismissed)

func _on_jump_hint_requested() -> void:
	visible = true
	_timer = 0.0
	_frame_index = 0
	texture = texture_released

func _on_jump_hint_dismissed() -> void:
	visible = false

func _process(delta: float) -> void:
	if not visible:
		return
	_timer += delta
	if _timer >= PRESS_INTERVAL:
		_timer = 0.0
		_frame_index = (_frame_index + 1) % 3
		match _frame_index:
			0:
				texture = texture_released
			1:
				texture = texture_pressed
			2:
				texture = texture_woaaw
