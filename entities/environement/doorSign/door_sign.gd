extends Node2D

@export var linked_door: NodePath
@export var room_name: String = ""

const COLOR_LOCKED: Color = Color(1.0, 0.1, 0.1)
const COLOR_UNLOCKED: Color = Color(0.1, 1.0, 0.1)

@onready var _label: Label = $Label
@onready var _sign_light: PointLight2D = $SignLight

func _ready() -> void:
	_label.text = room_name
	var door: StaticBody2D = get_node(linked_door) as StaticBody2D
	if not door.is_locked:
		_label.add_theme_color_override("font_color", COLOR_UNLOCKED)
		_sign_light.color = COLOR_UNLOCKED
	else:
		_label.add_theme_color_override("font_color", COLOR_LOCKED)
		_sign_light.color = COLOR_LOCKED
	EventBus.door_unlocked.connect(_on_door_unlocked)
	EventBus.game_reset.connect(_on_game_reset)
	
func _on_door_unlocked(door: StaticBody2D) -> void:
	if door == get_node(linked_door):
		_label.add_theme_color_override("font_color", COLOR_UNLOCKED)
		var tween: Tween = create_tween()
		tween.tween_property(_sign_light, "color", COLOR_UNLOCKED, 0.3)

func _on_game_reset() -> void:
	_label.add_theme_color_override("font_color", COLOR_LOCKED)
	_sign_light.color = COLOR_LOCKED
