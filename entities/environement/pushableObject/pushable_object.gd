extends AnimatableBody2D

@export var limit_left: float = -INF
@export var limit_right: float = INF

const HOLD_DURATION: float = 0.5

var _player_ref: CharacterBody2D = null
var _push_direction: int = 0
var _is_being_pushed: bool = false
var _hold_timer: float = 0.0
var _player_in_range: bool = false

func _ready() -> void:
	$PushAreaLeft.body_entered.connect(_on_push_area_left_entered)
	$PushAreaLeft.body_exited.connect(_on_push_area_left_exited)
	$PushAreaRight.body_entered.connect(_on_push_area_right_entered)
	$PushAreaRight.body_exited.connect(_on_push_area_right_exited)

func _on_push_area_left_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_ref = body as CharacterBody2D
		_push_direction = 1
		_player_in_range = true
		EventBus.interaction_available.emit("Hold E to push")

func _on_push_area_left_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
		_full_cancel()

func _on_push_area_right_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_ref = body as CharacterBody2D
		_push_direction = -1
		_player_in_range = true
		EventBus.interaction_available.emit("Hold E to push")

func _on_push_area_right_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
		_full_cancel()

func _physics_process(delta: float) -> void:
	if _player_ref == null:
		return

	if _is_being_pushed:
		_handle_push(delta)
		if not Input.is_action_pressed("interact"):
			_stop_push()
		return

	if Input.is_action_pressed("interact") and _player_ref.is_on_floor():
		_hold_timer += delta
		if _hold_timer >= HOLD_DURATION:
			_start_push()
	else:
		_hold_timer = 0.0

func _start_push() -> void:
	_is_being_pushed = true
	_player_ref.is_pushing = true
	_player_ref.push_direction = _push_direction
	EventBus.interaction_unavailable.emit()

func _handle_push(delta: float) -> void:
	var player_input: float = Input.get_axis("move_left", "move_right")
	var input_direction: int = sign(player_input) as int

	if input_direction == 0 or input_direction != _push_direction:
		return

	var displacement: Vector2 = Vector2(_player_ref.speed * player_input * delta, 0.0)

	# clamp AVANT le mouvement, sur la position cible
	var target_x: float = clamp(global_position.x + displacement.x, limit_left, limit_right)
	displacement.x = target_x - global_position.x

	move_and_collide(displacement)

func _stop_push() -> void:
	_is_being_pushed = false
	_hold_timer = 0.0
	if _player_ref != null:
		_player_ref.is_pushing = false
		_player_ref.push_direction = 0
	if _player_in_range:
		EventBus.interaction_available.emit("Hold E to push")

func _full_cancel() -> void:
	_is_being_pushed = false
	_hold_timer = 0.0
	if _player_ref != null:
		_player_ref.is_pushing = false
		_player_ref.push_direction = 0
	_player_ref = null
	_push_direction = 0
	EventBus.interaction_unavailable.emit()
