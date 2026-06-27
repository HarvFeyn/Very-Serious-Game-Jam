extends Area2D

@onready var _light: PointLight2D = $PointLight2D

var is_active: bool = false
var _pulse_tween: Tween

func _ready() -> void:
	_light.visible = false
	input_pickable = true
	monitoring = true
	monitorable = true
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func activate() -> void:
	is_active = true
	_light.visible = true
	if _pulse_tween:
		_pulse_tween.kill()
	_pulse_tween = create_tween().set_loops()
	_pulse_tween.tween_property(_light, "energy", 5.0, 0.2)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_pulse_tween.tween_property(_light, "energy", 2.0, 0.2)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func deactivate() -> void:
	is_active = false
	_light.visible = false
	if _pulse_tween:
		_pulse_tween.kill()
		_pulse_tween = null
	_light.energy = 3.0

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	print("input event received: ", event)
	if event is InputEventMouseButton \
			and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:
		get_parent().get_parent().on_button_clicked(is_active)

func _on_mouse_entered() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
