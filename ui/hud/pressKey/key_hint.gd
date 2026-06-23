extends Node2D

@export var texture_released: Texture2D
@export var texture_pressed: Texture2D

const PRESS_INTERVAL: float = 0.3

@onready var _sprite: Sprite2D = $Sprite2D

var _timer: float = 0.0
var _is_pressed: bool = false

func _ready() -> void:
	_sprite.texture = texture_released
	_sprite.z_index = 10

func _process(delta: float) -> void:
	if not visible:
		return
	_timer += delta
	if _timer >= PRESS_INTERVAL:
		_timer = 0.0
		_is_pressed = !_is_pressed
		_sprite.texture = texture_pressed if _is_pressed else texture_released
