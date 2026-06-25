extends VBoxContainer

@export var quest_texts: Array[String] = [
	"- Réparer la salle 1",
	"- Réparer la salle 2",
	"- Réparer la salle 3"
]

const COLOR_ACTIVE: Color = Color(0.0, 0.0, 0.0, 1.0)
const COLOR_DONE: Color = Color(0.0, 0.379, 0.129, 1.0)

var _labels: Array[RichTextLabel] = []
var _completed_count: int = 0

func _ready() -> void:

	var label1: RichTextLabel = $Quest1
	label1.text = quest_texts[0]
	label1.add_theme_color_override("font_color", COLOR_ACTIVE)
	_labels.append(label1)
	var label2: RichTextLabel = $Quest2
	label2.text = quest_texts[1]
	label2.add_theme_color_override("font_color", COLOR_ACTIVE)
	_labels.append(label2)
	var label3: RichTextLabel = $Quest3
	label3.text = quest_texts[2]
	label3.add_theme_color_override("font_color", COLOR_ACTIVE)
	_labels.append(label3)
	EventBus.tier_advanced.connect(_on_tier_advanced)
	EventBus.game_reset.connect(_on_game_reset)

func _on_tier_advanced(_tier: int) -> void:
	if _completed_count >= _labels.size():
		return
	_complete_quest(_completed_count)
	_completed_count += 1

func _complete_quest(index: int) -> void:
	var label: RichTextLabel = _labels[index]
	label.text = "[s]" + quest_texts[index] + "[/s]"
	label.add_theme_color_override("font_color", COLOR_DONE)

func _on_game_reset() -> void:
	_completed_count = 0
	for i: int in _labels.size():
		_labels[i].text = quest_texts[i]
		_labels[i].add_theme_color_override("font_color", COLOR_ACTIVE)
