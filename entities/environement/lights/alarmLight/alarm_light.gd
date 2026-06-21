extends PointLight2D

@export var on_duration: float = 0.5
@export var off_duration: float = 0.5

var _is_blinking: bool = false

func _ready() -> void:
	visible = false
	EventBus.power_recharged.connect(_on_power_recharged)
	EventBus.power_depleted.connect(_on_power_depleted)

	if not PowerManager.is_powered:
		_start_blinking()

func _on_power_recharged() -> void:
	_is_blinking = false
	visible = false

func _on_power_depleted() -> void:
	_start_blinking()

func _start_blinking() -> void:
	if _is_blinking:
		return
	_is_blinking = true
	_blink_loop()

func _blink_loop() -> void:
	while _is_blinking:
		visible = true
		await get_tree().create_timer(on_duration).timeout
		if not _is_blinking:
			break
		visible = false
		await get_tree().create_timer(off_duration).timeout
