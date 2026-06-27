extends Node2D

@export var texture_released: Texture2D
@export var texture_pressed: Texture2D
@export var texture_woaaaw: Texture2D

const PRESS_INTERVAL: float = 0.3

@onready var _sprite: Sprite2D = $Sprite2D

var _timer: float = 0.0
var _frame_index: int = 0

func _ready() -> void:
	_sprite.texture = texture_released
	_sprite.z_index = 10

func _process(delta: float) -> void:
	if not visible:
		return
	_timer += delta
	if _timer >= PRESS_INTERVAL:
		_timer = 0.0
		_frame_index = (_frame_index + 1) % 3
		match _frame_index:
			0:
				_sprite.texture = texture_released
			1:
				_sprite.texture = texture_pressed
			2:
				_sprite.texture = texture_woaaaw
