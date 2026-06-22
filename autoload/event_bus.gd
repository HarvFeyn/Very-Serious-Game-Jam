extends Node

signal interaction_available(prompt_text: String)
signal interaction_unavailable

signal power_recharged
signal power_depleted
signal power_color_changed(color: Color)
signal alarm_activated
signal alarm_deactivated

signal game_reset

signal wheel_progress_changed(progress: float)
signal wheel_started
signal wheel_completed
