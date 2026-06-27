extends Sprite2D

func _ready() -> void:
	EventBus.interaction_available.connect(_on_interaction_available)
	EventBus.interaction_unavailable.connect(_on_interaction_unavailable)

func _on_interaction_available(_text: String) -> void:
	if material:
		material.set_shader_parameter("enabled", true)

func _on_interaction_unavailable() -> void:
	if material:
		material.set_shader_parameter("enabled", false)
