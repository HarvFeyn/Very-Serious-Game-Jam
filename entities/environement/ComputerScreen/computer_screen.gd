extends Node2D

@export var ambient_sound: AudioStream
@export var success_sound: AudioStream
@export var fail_sound: AudioStream
@export var finish_sound: AudioStream
@export var arm_sprite: Sprite2D

const LAMPS_REQUIRED: int = 10
const BASE_TIME: float = 3.0
const MIN_TIME: float = 0.3
const ARM_TWEEN_SPEED: float = 0.15
const ARM_MAX_X: float = 250.0
const ARM_MAX_Y: float = 200.0
const ARM_MAX_ROTATION: float = 1.0
const ARM_BASE_ROTATION: float = PI

var _current_progress: int = 0
var _button_timer: float = 0.0
var _current_button_time: float = BASE_TIME
var _is_running: bool = false
var _player_ref: CharacterBody2D = null
var _ambient_player: AudioStreamPlayer = null
var _buttons: Array = []
var _lamps: Array = []

var _arm_tween: Tween
var _arm_base_position: Vector2
var _arm_base_rotation: float = ARM_BASE_ROTATION

func _ready() -> void:
	_buttons = $Buttons.get_children()
	_lamps = $Lamps.get_children()
	visible = false
	_init_lamps()
	EventBus.game_reset.connect(_on_game_reset)
	_current_progress = 0
	_current_button_time = BASE_TIME
	if arm_sprite:
		_arm_base_position = arm_sprite.position
		arm_sprite.rotation = ARM_BASE_ROTATION
		
func start(player: CharacterBody2D) -> void:
	_set_music_lowpass(true)
	_player_ref = player
	_player_ref.controls_enabled = false
	_player_ref.velocity = Vector2.ZERO

	var cam: Camera2D = player.get_node("Camera2D")
	cam.reset_smoothing()

	await get_tree().process_frame
	await get_tree().process_frame

	global_position = cam.get_screen_center_position()
	visible = true
	_is_running = true
	_update_lamps()
	_activate_random_button()
	_start_ambient()
	
func _process(delta: float) -> void:
	if not _is_running:
		return

	if Input.is_action_just_pressed("interact") \
			or Input.is_action_just_pressed("move_left") \
			or Input.is_action_just_pressed("move_right") \
			or Input.is_action_just_pressed("jump"):
		_exit()
		return

	_button_timer -= delta
	if _button_timer <= 0.0:
		_on_timeout()
		
	if arm_sprite:
		_update_arm()
		
func on_button_clicked(correct: bool) -> void:
	if not _is_running:
		return
	if correct:
		AudioManager.play_sfx(success_sound)
		_current_progress = min(_current_progress + 1, LAMPS_REQUIRED)
		if _current_progress >= LAMPS_REQUIRED:
			_complete()
			return
	else:
		AudioManager.play_sfx(fail_sound)
		_current_progress = max(_current_progress - 1, 0)
	_update_lamps()
	_deactivate_all_buttons()
	_update_difficulty()
	_activate_random_button()

func _on_timeout() -> void:
	_current_progress = max(_current_progress - 1, 0)
	_update_lamps()
	_deactivate_all_buttons()
	_activate_random_button()

func _activate_random_button() -> void:
	_deactivate_all_buttons()
	var index: int = randi() % _buttons.size()
	_buttons[index].activate()
	_button_timer = _current_button_time

func _deactivate_all_buttons() -> void:
	for button: Area2D in _buttons:
		button.deactivate()

func _update_difficulty() -> void:
	var ratio: float = float(_current_progress) / float(LAMPS_REQUIRED)
	_current_button_time = lerpf(BASE_TIME, MIN_TIME, ratio)

func _update_lamps() -> void:
	for i: int in _lamps.size():
		var lamp: PointLight2D = _lamps[i] as PointLight2D
		lamp.visible = i < _current_progress

func _init_lamps() -> void:
	for lamp: PointLight2D in _lamps:
		var point_light: PointLight2D = lamp as PointLight2D
		point_light.visible = false

func _complete() -> void:
	AudioManager.play_sfx(finish_sound,10.0)
	_set_music_lowpass(false)
	_stop_ambient()
	_is_running = false
	_deactivate_all_buttons()
	_update_lamps()
	if _player_ref:
		_player_ref.controls_enabled = true
	visible = false
	EventBus.quest_discovered.emit(7)

func _on_game_reset() -> void:
	_set_music_lowpass(false)
	_stop_ambient()
	_is_running = false
	_deactivate_all_buttons()
	_current_progress = 0
	_init_lamps()
	visible = false
	if _player_ref:
		_player_ref.controls_enabled = true
	_player_ref = null

func _input(event: InputEvent) -> void:
	if not _is_running or not visible:
		return
	if not (event is InputEventMouseButton):
		return
	var mouse_event: InputEventMouseButton = event as InputEventMouseButton
	if not mouse_event.pressed or mouse_event.button_index != MOUSE_BUTTON_LEFT:
		return
		
	var mouse_pos: Vector2 = get_global_mouse_position()
	var space: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var query: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
	query.position = mouse_pos
	query.collide_with_areas = true
	query.collide_with_bodies = false
	
	var results: Array[Dictionary] = space.intersect_point(query)
	for result: Dictionary in results:
		var collider: Object = result["collider"]
		for button: Area2D in _buttons:
			if collider == button:
				on_button_clicked(button.is_active)
				return

func _exit() -> void:
	_set_music_lowpass(false)
	_stop_ambient()
	_is_running = false
	_deactivate_all_buttons()
	visible = false
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	if _player_ref:
		_player_ref.controls_enabled = true
	
	if arm_sprite:
		arm_sprite.position = _arm_base_position
		arm_sprite.rotation = ARM_BASE_ROTATION
		
func _start_ambient() -> void:
	if ambient_sound == null:
		return
	_ambient_player = AudioStreamPlayer.new()
	_ambient_player.bus = AudioManager.BUS_SFX
	_ambient_player.stream = ambient_sound
	_ambient_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_ambient_player)
	_ambient_player.volume_db = 15.0
	_ambient_player.play()

func _stop_ambient() -> void:
	if _ambient_player == null:
		return
	var player: AudioStreamPlayer = _ambient_player
	_ambient_player = null
	var tween: Tween = create_tween()
	tween.tween_property(player, "volume_db", -80.0, 0.5)
	tween.finished.connect(player.queue_free)

func _set_music_lowpass(enabled: bool) -> void:
	var bus_index: int = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_effect_enabled(bus_index, 0, enabled)

func _update_arm() -> void:
	var mouse_pos: Vector2 = to_local(get_viewport().get_mouse_position())
	var diff: Vector2 = mouse_pos - _arm_base_position

	var target_x: float = clamp(diff.x * 0.3, -ARM_MAX_X, ARM_MAX_X)
	var target_y: float = clamp(-abs(diff.y) * 0.1, -ARM_MAX_Y, 0.0)

	var target_rotation: float = _arm_base_rotation + clamp(diff.x * 0.002, -ARM_MAX_ROTATION, ARM_MAX_ROTATION)

	var target_pos: Vector2 = _arm_base_position + Vector2(target_x, target_y)

	if _arm_tween:
		_arm_tween.kill()
	_arm_tween = create_tween()
	_arm_tween.set_parallel(true)
	_arm_tween.tween_property(arm_sprite, "position", target_pos, ARM_TWEEN_SPEED)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_arm_tween.tween_property(arm_sprite, "rotation", target_rotation, ARM_TWEEN_SPEED)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
