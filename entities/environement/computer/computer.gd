extends Node2D

@export var computer_screen: NodePath
@export var interaction_duration: float = 0.0

var _player_in_range: bool = false
var _player_ref: CharacterBody2D = null
var _is_used: bool = false

func _ready() -> void:
	$InteractionArea.body_entered.connect(_on_body_entered)
	$InteractionArea.body_exited.connect(_on_body_exited)
	EventBus.game_reset.connect(_on_game_reset)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = true
		_player_ref = body as CharacterBody2D
		if not _is_used:
			EventBus.interaction_available.emit("Press E to interact")

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
		if not _is_used:
			EventBus.interaction_unavailable.emit()

func _process(_delta: float) -> void:
	if _player_in_range and not _is_used and Input.is_action_just_pressed("interact"):
		_trigger()

func _trigger() -> void:
	_is_used = false
	EventBus.interaction_unavailable.emit()
	var screen: Node2D = get_node(computer_screen) as Node2D
	screen.start(_player_ref)

func _on_game_reset() -> void:
	_is_used = false
