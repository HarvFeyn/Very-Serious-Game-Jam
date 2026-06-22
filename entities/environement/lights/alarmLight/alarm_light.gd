extends PointLight2D

@export var on_duration: float = 0.7
@export var off_duration: float = 0.7

var _is_blinking: bool = false

func _ready() -> void:
	visible = false
	EventBus.alarm_activated.connect(_on_alarm_activated)
	EventBus.alarm_deactivated.connect(_on_alarm_deactivated)
	EventBus.game_reset.connect(_on_alarm_activated)

	_on_alarm_activated()

func _on_alarm_activated() -> void:
	if _is_blinking:
		return
	_is_blinking = true
	_blink_loop()

func _on_alarm_deactivated() -> void:
	_is_blinking = false
	visible = false

func _blink_loop() -> void:
	while _is_blinking:
		visible = true
		await get_tree().create_timer(on_duration).timeout
		if not _is_blinking:
			break
		visible = false
		await get_tree().create_timer(off_duration).timeout
