extends Control

@onready var label: Label = $CenterContainer/Label

func _ready() -> void:
	label.visible = false
	EventBus.interaction_available.connect(_on_interaction_available)
	EventBus.interaction_unavailable.connect(_on_interaction_unavailable)

func _on_interaction_available(text: String) -> void:
	label.text = text
	label.visible = true

func _on_interaction_unavailable() -> void:
	label.visible = false
