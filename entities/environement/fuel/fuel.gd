extends Node2D

@export var engine: NodePath
@export var player_fuel_offset: Vector2 = Vector2(95, 20)
@export var fuel_offset: Vector2 = Vector2(-24, -16)
@export var interaction_duration: float = 5.0
@onready var _light: PointLight2D = $PointLight2D

var _player_in_range: bool = false
var _player_ref: CharacterBody2D = null
var _is_used: bool = false
var _pulse_tween: Tween

func _ready() -> void:
	$InteractionArea.body_entered.connect(_on_body_entered)
	$InteractionArea.body_exited.connect(_on_body_exited)
	EventBus.game_reset.connect(_on_game_reset)
	_start_pulse()
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = true
		_player_ref = body as CharacterBody2D
		if not _is_used:
			EventBus.interaction_available.emit("Press E to push fuel")

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
		if not _is_used:
			EventBus.interaction_unavailable.emit()

func _process(_delta: float) -> void:
	if _player_in_range and not _is_used and Input.is_action_just_pressed("interact"):
		_trigger()

func _trigger() -> void:
	_is_used = true
	EventBus.interaction_unavailable.emit()
	_stop_pulse()
	visible = false
	var engine_node: CatEngine = get_node(engine) as CatEngine
	engine_node.on_fuel_inserted()
	_player_ref.is_in_lock_mode = true
	_player_ref.global_position = global_position + player_fuel_offset
	_player_ref.sprite.flip_h = true
	_player_ref.sprite.play("push")
	await get_tree().create_timer(interaction_duration).timeout
	_player_ref.sprite.stop()
	_player_ref.is_in_lock_mode = false
	
func _on_game_reset() -> void:
	_is_used = false
	visible = true
	_start_pulse()

func _start_pulse() -> void:
	if _pulse_tween:
		_pulse_tween.kill()
	_pulse_tween = create_tween().set_loops()
	_pulse_tween.tween_property(_light, "energy", 3.0, 1.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_pulse_tween.tween_property(_light, "energy", 0, 1.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _stop_pulse() -> void:
	if _pulse_tween:
		_pulse_tween.kill()
		_pulse_tween = null
	_light.energy = 0.0
	_light.visible = false
