extends CharacterBody2D

@export var speed: float = 400.0
@export var jump_force: float = -800.0
@export var gravity: float = 1500.0

const JUMP_SOUND: AudioStream = preload("res://entities/player/audio/Saut1.mp3")
const LAND_SOUND: AudioStream = preload("res://entities/player/audio/Atterissage-choc.mp3")

var controls_enabled: bool = true
var is_in_wheel_mode: bool = false
var is_pushing: bool = false
var push_direction: int = 0

var _was_on_floor: bool = false

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

	var direction:float = Input.get_axis("move_left", "move_right")
	var input_direction: int = sign(direction) as int

	if is_pushing and input_direction != push_direction:
		velocity.x = 0.0
	else:
		velocity.x = direction * speed

	# saut
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_pushing:
		velocity.y = jump_force
		AudioManager.play_sfx(JUMP_SOUND,-10.0)

	move_and_slide()

	if not _was_on_floor and is_on_floor():
		#AudioManager.play_sfx(LAND_SOUND)
		pass

	_was_on_floor = is_on_floor()

	if direction != 0 and not is_pushing:
		scale.x = sign(direction)

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0.0
