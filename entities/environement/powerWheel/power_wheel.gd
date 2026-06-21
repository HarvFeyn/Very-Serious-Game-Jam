extends Node2D

var player_in_range: bool = false

func _ready() -> void:
	$InteractionArea.body_entered.connect(_on_body_entered)
	$InteractionArea.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		EventBus.interaction_available.emit("Press E to interact")

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		EventBus.interaction_unavailable.emit()

func _process(_delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("interact"):
		PowerManager.recharge()
