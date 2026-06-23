extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $sprite
@onready var _collision: CollisionShape2D = $CollisionShape2D
@export var collision_offset_x: float = 29.0
@export var collision_offset_y: float = 5.0

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
		
	sprite.speed_scale = 1.0
	
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
		pass

	_was_on_floor = is_on_floor()

	if direction != 0:
		sprite.play("run")
		_update_direction(direction)
	else:
		sprite.stop()

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0.0

func _update_direction(direction: float) -> void:
	if direction > 0:
		sprite.flip_h = false
		_collision.position.x = collision_offset_x
	elif direction < 0:
		sprite.flip_h = true
		_collision.position.x = -collision_offset_x
