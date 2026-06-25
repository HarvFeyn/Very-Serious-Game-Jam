extends Area2D

@export var permanent_dismiss: bool = false

func _ready() -> void:
	if permanent_dismiss and Globals.jump_hint_permanently_dismissed:
		queue_free()
		return
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if permanent_dismiss:
		Globals.jump_hint_permanently_dismissed = true
		EventBus.jump_hint_dismissed.emit()
		queue_free()
	else:
		if not Globals.jump_hint_permanently_dismissed:
			EventBus.jump_hint_requested.emit()

func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player") or permanent_dismiss:
		return
	EventBus.jump_hint_dismissed.emit()
