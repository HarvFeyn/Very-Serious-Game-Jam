extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $sprite
@onready var _collision: CollisionShape2D = $CollisionShape2D
@export var collision_offset_x: float = 29.0
@export var collision_offset_y: float = 5.0

@export var speed: float = 400.0
@export var push_speed_multiplier: float = 0.5
@export var jump_force: float = -750.0
@export var gravity: float = 1500.0


const JUMP_SOUND: AudioStream = preload("res://entities/player/audio/Saut1.mp3")
const LAND_SOUND: AudioStream = preload("res://entities/player/audio/Atterissage-choc.mp3")
const footstep_sound: AudioStream = preload("res://entities/player/audio/Chat qui marche sur du metal.mp3")
const PEAK_DISPLAY_DURATION: float = 0.2

var _footstep_player: AudioStreamPlayer = null

var _base_speed: float
var controls_enabled: bool = true
var is_in_lock_mode: bool = false
var is_pushing: bool = false
var push_direction: int = 0
var _is_jumping: bool = false
var _jump_peak_reached: bool = false
var _previous_velocity_y: float = 0.0
var _peak_timer: float = 0.0
var _was_on_floor: bool = false

func _ready() -> void:
	_base_speed = speed
	
func _physics_process(delta: float) -> void:
	
	var direction:float = Input.get_axis("move_left", "move_right")
	var input_direction: int = sign(direction) as int
	
	if direction != 0 and is_on_floor() and not is_pushing and not is_in_lock_mode and controls_enabled:
		_start_footsteps()
	else:
		_stop_footsteps()
		
	if is_in_lock_mode:
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
		
	if is_pushing and input_direction != push_direction:
		velocity.x = 0.0
	else:
		velocity.x = direction * speed

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
		AudioManager.play_sfx(JUMP_SOUND)
		_is_jumping = true
		_jump_peak_reached = false
		sprite.animation = "jump"
		sprite.stop()
		sprite.frame = 0

	move_and_slide()

	if not _was_on_floor and is_on_floor():
		pass
	
	if not _was_on_floor and is_on_floor():
		_is_jumping = false
		_jump_peak_reached = false
		
	_was_on_floor = is_on_floor()
	
	if not is_pushing:
		if direction != 0:
			sprite.play("run")
			_update_direction(direction)
		else:
			sprite.stop()
			
	_update_animation(direction)	
	_previous_velocity_y = velocity.y

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0.0

func _update_direction(direction: float) -> void:
	if direction > 0:
		sprite.flip_h = false
		_collision.position.x = collision_offset_x
		$InteractionHint.position.x = abs($InteractionHint.position.x)
	elif direction < 0:
		sprite.flip_h = true
		_collision.position.x = -collision_offset_x
		$InteractionHint.position.x = -abs($InteractionHint.position.x)
		
func _update_animation(direction: float) -> void:
	if is_in_lock_mode:
		return

	if is_pushing:
		sprite.play("push")
		return

	if not is_on_floor():
		sprite.animation = "jump"
		sprite.stop()

		if velocity.y >= 0 and _previous_velocity_y < 0:
			_jump_peak_reached = true
			_peak_timer = PEAK_DISPLAY_DURATION
			sprite.frame = 1  # sommet

		if _peak_timer > 0.0:
			_peak_timer -= get_physics_process_delta_time()
			sprite.frame = 1  # garde le sommet affiché
		elif _jump_peak_reached:
			sprite.frame = 2  # descente
		else:
			sprite.frame = 0  # montée
		return

	_jump_peak_reached = false
	_peak_timer = 0.0

	if direction != 0:
		sprite.play("run")
	else:
		sprite.play("idle")

func _start_footsteps() -> void:
	if _footstep_player != null or footstep_sound == null:
		return
	_footstep_player = AudioStreamPlayer.new()
	_footstep_player.bus = AudioManager.BUS_SFX
	_footstep_player.stream = footstep_sound
	_footstep_player.volume_db = 0.0
	_footstep_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_footstep_player)
	_footstep_player.play()

func _stop_footsteps() -> void:
	if _footstep_player == null:
		return
	var player: AudioStreamPlayer = _footstep_player
	_footstep_player = null
	var tween: Tween = create_tween()
	tween.tween_property(player, "volume_db", -80.0, 0.1)
	tween.finished.connect(player.queue_free)
