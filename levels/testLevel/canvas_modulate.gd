extends CanvasModulate

func _ready() -> void:
	color = PowerManager.DARK_COLOR
	EventBus.power_color_changed.connect(_on_power_color_changed)

func _on_power_color_changed(new_color: Color) -> void:
	color = new_color
