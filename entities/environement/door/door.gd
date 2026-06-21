extends StaticBody2D

@export var target_level_path: NodePath
@export var spawn_marker_path: NodePath
@export var walk_in_offset: Vector2 = Vector2(40, 0)
@export var start_unlocked: bool = false

var is_locked: bool = true
var puzzle_solved: bool = true
var player_in_range: bool = false

func _ready() -> void:
	$InteractionArea.body_entered.connect(_on_interaction_area_entered)
	$InteractionArea.body_exited.connect(_on_interaction_area_exited)
	$CrossingArea.body_entered.connect(_on_crossing_area_entered)

	if start_unlocked:
		unlock()

func _on_interaction_area_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	player_in_range = true
	if is_locked:
		EventBus.interaction_available.emit("Press E to interact")

func _on_interaction_area_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		if is_locked:
			EventBus.interaction_unavailable.emit()

func _on_crossing_area_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_locked:
		var player_body: CharacterBody2D = body as CharacterBody2D
		_trigger_transition(player_body)

func _process(_delta: float) -> void:
	if player_in_range and is_locked and puzzle_solved and Input.is_action_just_pressed("interact"):
		unlock()

func unlock() -> void:
	is_locked = false
	$CollisionShape2D.set_deferred("disabled", true)
	$ColorRect.color = Color(0.2, 0.8, 0.2, 0.5)
	EventBus.interaction_unavailable.emit()

func _trigger_transition(player_body: CharacterBody2D) -> void:
	var target_level: GameLevel = get_node(target_level_path) as GameLevel
	var spawn_marker: Marker2D = get_node(spawn_marker_path) as Marker2D
	LevelManager.go_to_level_with_walk_in(player_body, target_level, spawn_marker, walk_in_offset)
