extends Node


enum Stage {
	INTRO,
	WHEEL_ROOM,
	LITTER_UNLOCKED,
	ENGINE_ROOM,
	ENGINE_OVERHEAT,
	COCKPIT,
	COCKPIT_PUZZLE,
	FINALE,
	AIRLOCK_OPEN,
	ENDED,
}

const CRITICAL_MESSAGES: Array[String] = [
	"Power critical. Spin the wheel or enjoy the dark. Your call, brave kitty.",
	"Power almost gone. Wheel. Spin. Now. We can discuss the details later.",
	"Critical power. Fun fact: cats can't actually see in complete darkness. Spin. Fast."
]

signal stage_changed(stage: Stage)

var current_stage: Stage = Stage.INTRO
var _power_critical_call: bool = true
var current_quest_index: int = -1
var current_power_tier: PowerManager.PowerTier = PowerManager.PowerTier.TIER_1

func _ready() -> void:
	EventBus.quest_discovered.connect(_on_quest_discovered)
	EventBus.tier_advanced.connect(_on_tier_advanced)
	EventBus.power_critical.connect(_on_power_critical)
	EventBus.power_recharged.connect(_on_power_recharged)
	EventBus.game_reset.connect(_on_game_reset)

func _on_quest_discovered(index: int) -> void:
	current_quest_index = index
	match index:
		0:
			_set_stage(Stage.INTRO)
			EventBus.ai_message.emit("Power failure detected. Life support: minimal.")
		1:
			_set_stage(Stage.WHEEL_ROOM)
			EventBus.ai_message.emit("Power restored. Resuming operations.")
		2:
			_set_stage(Stage.LITTER_UNLOCKED)
			EventBus.ai_message.emit("Door unlocked. ...by cat litter. Noted.")
		3:
			_set_stage(Stage.ENGINE_ROOM)
			EventBus.ai_message.emit("Engine room access granted. Caution: overheating risk.")
		4:
			_set_stage(Stage.ENGINE_OVERHEAT)
			EventBus.ai_message.emit("That engine is having a moment. Please help it calm down.")
		5:
			_set_stage(Stage.COCKPIT)
			EventBus.ai_message.emit("Gravity control offline. Proceed with caution.")
		6:
			_set_stage(Stage.COCKPIT_PUZZLE)
			EventBus.ai_message.emit("Autopilot offline. Hit the buttons. All of them.")
		7:
			_set_stage(Stage.FINALE)
			EventBus.ai_message.emit("Warning: cable failure detected. Immediate action required.")
		8:
			_set_stage(Stage.AIRLOCK_OPEN)
			EventBus.ai_message.emit("Airlock open. Welcome back.")
			
func _on_tier_advanced(tier: int) -> void:
	current_power_tier = tier as PowerManager.PowerTier

func _on_power_recharged() -> void:
	_power_critical_call = false
	EventBus.ai_message.emit("Power restored. Resuming operations.")

func _on_power_critical() -> void:
	if _power_critical_call:
		return
	var message: String = CRITICAL_MESSAGES[randi() % CRITICAL_MESSAGES.size()]
	EventBus.ai_message.emit(message)
	_power_critical_call = true

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
