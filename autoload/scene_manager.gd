extends Node

const MAIN_MENU: PackedScene = preload("res://ui/menus/main_menu/main_menu.tscn")
const OPTIONS_MENU: PackedScene = preload("res://ui/menus/options_menu/options_menu.tscn")
const GAME: PackedScene = preload("res://core/game/game.tscn")
const CREDITS: PackedScene = preload("res://core/credits/credits.tscn")

var _scene_container: Node
var _current_scene: Node = null

func init(scene_container: Node) -> void:
	_scene_container = scene_container
	_change_scene(MAIN_MENU)

func go_to_game() -> void:
	_change_scene(GAME)

func go_to_main_menu() -> void:
	_change_scene(MAIN_MENU)

func go_to_credits() -> void:
	_change_scene(CREDITS)
	
func go_to_options() -> void:
	var options: OptionsMenu = OPTIONS_MENU.instantiate()
	options.context = SceneEnums.OptionsContext.MAIN_MENU
	_change_scene(OPTIONS_MENU)

func _change_scene(new_scene: PackedScene, exit_behavior: SceneEnums.SceneExitBehavior = SceneEnums.SceneExitBehavior.DELETE) -> void:
	if _current_scene != null:
		match exit_behavior:
			SceneEnums.SceneExitBehavior.DELETE:
				_current_scene.queue_free()
			SceneEnums.SceneExitBehavior.HIDE:
				_current_scene.visible = false
			SceneEnums.SceneExitBehavior.PAUSE:
				_current_scene.visible = false
				_current_scene.process_mode = Node.PROCESS_MODE_DISABLED
	_current_scene = new_scene.instantiate()
	_scene_container.add_child(_current_scene)
