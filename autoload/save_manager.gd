# save_manager.gd
extends Node

const SAVE_PATH: String = "user://settings.cfg"

func save(data: Dictionary) -> void:
	if OS.has_feature("web") and not _is_web_storage_available():
		push_warning("SaveManager: stockage non disponible")
		return
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: impossible d'ouvrir le fichier en écriture")
		return
	file.store_string(JSON.stringify(data))

func load_data() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("SaveManager: impossible d'ouvrir le fichier en lecture")
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed == null:
		push_error("SaveManager: fichier corrompu")
		return {}
	return parsed

func _is_web_storage_available() -> bool:
	return JavaScriptBridge.eval("typeof(Storage) !== 'undefined'")
