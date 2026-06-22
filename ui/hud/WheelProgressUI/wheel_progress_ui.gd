extends Control

@onready var bar: ProgressBar = $ProgressBar

func _ready() -> void:
	visible = false
	EventBus.wheel_started.connect(_on_wheel_started)
	EventBus.wheel_progress_changed.connect(_on_progress_changed)
	EventBus.wheel_completed.connect(_on_wheel_completed)

func _on_wheel_started() -> void:
	visible = true
	bar.value = 0

func _on_progress_changed(progress: float) -> void:
	bar.value = progress * 100.0

func _on_wheel_completed() -> void:
	visible = false
