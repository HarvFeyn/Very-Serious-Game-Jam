extends CharacterBody2D

@export var speed: float = 300.0
@export var jump_force: float = -800.0
@export var gravity: float = 1500.0

var controls_enabled: bool = true
var is_in_wheel_mode: bool = false
var is_pushing: bool = false
var push_direction: int = 0

func _physics_process(delta: float) -> void:
	if is_in_wheel_mode:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if not controls_enabled:
		velocity.x = 0.0
		_apply_gravity(delta)
		move_and_slide()
		return

	_apply_gravity(delta)

	var direction: float = Input.get_axis("move_left", "move_right")
	var input_direction: int = sign(direction) as int

	if is_pushing and input_direction != push_direction:
		velocity.x = 0.0
	else:
		velocity.x = direction * speed

	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_pushing:
		velocity.y = jump_force

	move_and_slide()

	if direction != 0 and not is_pushing:
		scale.x = sign(direction)

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0.0
