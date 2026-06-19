# settings_manager.gd (AutoLoad)
extends Node

const SETTINGS_KEY: String = "settings"

var _settings: Dictionary = {
	"audio": { "master": 0.5, "music": 0.5, "sfx": 0.5 },
	"video": { "fullscreen": false },
}

func _ready() -> void:
	_load()

func get_setting(category: String, key: String) -> Variant:
	return _settings.get(category, {}).get(key)

func set_setting(category: String, key: String, value: Variant) -> void:
	if not _settings.has(category):
		_settings[category] = {}
	_settings[category][key] = value

func save() -> void:
	var data: Dictionary = SaveManager.load_data()
	data[SETTINGS_KEY] = _settings
	SaveManager.save(data)

func _load() -> void:
	var data: Dictionary = SaveManager.load_data()
	if data.has(SETTINGS_KEY):
		_settings.merge(data[SETTINGS_KEY], true)
