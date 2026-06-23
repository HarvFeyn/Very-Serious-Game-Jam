extends PointLight2D

const TWEEN_DURATION: float = 0.5

func _ready() -> void:
	color = GameColors.WHEEL_LIGHT_UNPOWERED_COLOR
	energy = 2.0
	EventBus.power_recharged.connect(_on_power_recharged)
	EventBus.power_depleted.connect(_on_power_depleted)
	EventBus.game_reset.connect(_on_power_depleted)

func _on_power_recharged() -> void:
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "energy", 1.0, TWEEN_DURATION)
	tween.tween_property(self, "color", GameColors.LIGHT_POWERED_COLOR, TWEEN_DURATION)

func _on_power_depleted() -> void:
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "energy", 2.0, TWEEN_DURATION)
	tween.tween_property(self, "color", GameColors.WHEEL_LIGHT_UNPOWERED_COLOR, TWEEN_DURATION)
