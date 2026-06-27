extends Node

signal interaction_available(prompt_text: String)
signal interaction_unavailable

signal power_recharged
signal power_depleted
signal power_critical
signal power_color_changed(color: Color)
signal alarm_activated
signal alarm_deactivated

signal game_reset

signal wheel_progress_changed(progress: float)
signal wheel_started
signal wheel_completed

signal safe_zone_entered
signal safe_zone_exited

signal door_unlocked(door: StaticBody2D)

signal pee_changed(value: float)
signal pee_full

signal litter_used

signal tier_advanced(tier: int)

signal power_level_changed(ratio: float)

signal jump_hint_requested
signal jump_hint_dismissed

signal quest_discovered(index: int)
signal ai_message(text: String)

signal level_changed(active_level: GameLevel)
