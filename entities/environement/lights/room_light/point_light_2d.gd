extends PointLight2D

const TWEEN_DURATION: float = 0.5

func _ready() -> void:
	color = GameColors.LIGHT_POWERED_COLOR
	energy = 0.0
	EventBus.power_recharged.connect(_on_power_recharged)
	EventBus.power_depleted.connect(_on_power_depleted)
	EventBus.game_reset.connect(_on_power_depleted)

func _on_power_recharged() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "energy", 1.0, TWEEN_DURATION)

func _on_power_depleted() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "energy", 0.0, TWEEN_DURATION)
