extends Node2D

@export var engine: NodePath
@export var turn_sound: AudioStream

var _player_in_range: bool = false
var _is_turned: bool = false

func _ready() -> void:
	$InteractionArea.body_entered.connect(_on_body_entered)
	$InteractionArea.body_exited.connect(_on_body_exited)
	EventBus.game_reset.connect(_on_game_reset)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = true
		if not _is_turned:
			EventBus.interaction_available.emit("Press E to turn valve")

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
		EventBus.interaction_unavailable.emit()

func _process(_delta: float) -> void:
	if _player_in_range and not _is_turned and Input.is_action_just_pressed("interact"):
		_trigger()

func _trigger() -> void:
	_is_turned = true
	EventBus.interaction_unavailable.emit()
	if turn_sound:
		AudioManager.play_sfx(turn_sound, 10.0)
	var engine_node: CatEngine = get_node(engine) as CatEngine
	engine_node.on_valve_turned()

func _on_game_reset() -> void:
	_is_turned = false
