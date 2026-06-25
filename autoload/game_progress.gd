extends Node



enum Stage {
	INTRO,
	WHEEL_ROOM,
	ENGINE_ROOM,
	COCKPIT,
	FINALE,
	ENDED,
}

signal stage_changed(stage: Stage)

var current_stage: Stage = Stage.INTRO


var current_quest_index: int = -1


var current_power_tier: PowerManager.PowerTier = PowerManager.PowerTier.TIER_1


func _ready() -> void:
	print("GameProgress actif")
	EventBus.quest_discovered.connect(_on_quest_discovered)
	EventBus.tier_advanced.connect(_on_tier_advanced)
	EventBus.power_depleted.connect(_on_power_depleted)
	EventBus.power_recharged.connect(_on_power_recharged)
	EventBus.game_reset.connect(_on_game_reset)


func _on_quest_discovered(index: int) -> void:
	current_quest_index = index

	match index:
		0:
			_set_stage(Stage.WHEEL_ROOM)
		1:
			_set_stage(Stage.ENGINE_ROOM)
			EventBus.ai_message.emit("Engine room access granted. Caution: overheating risk.")
		2:
			_set_stage(Stage.COCKPIT)
			EventBus.ai_message.emit("Gravity control offline. Proceed with caution.")
		3:
			_set_stage(Stage.FINALE)
			EventBus.ai_message.emit("Warning: cable failure detected. Immediate action required.")


func _on_tier_advanced(tier: int) -> void:
	current_power_tier = tier as PowerManager.PowerTier



func _on_power_recharged() -> void:
	EventBus.ai_message.emit("Power restored. Resuming operations.")


func _on_power_depleted() -> void:
	EventBus.ai_message.emit("Energy critical. Return to the wheel room.")


func _on_game_reset() -> void:
	current_stage = Stage.INTRO
	current_quest_index = -1
	current_power_tier = PowerManager.PowerTier.TIER_1


func _set_stage(stage: Stage) -> void:
	if stage == current_stage:
		return
	current_stage = stage
	stage_changed.emit(stage)



func is_at_least(stage: Stage) -> bool:
	return current_stage >= stage
