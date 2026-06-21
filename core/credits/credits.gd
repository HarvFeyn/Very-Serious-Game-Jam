extends Control
@onready var background: ColorRect = $ColorRect
func _ready() -> void:
	background.color = GameColors.SECONDARY

func _on_back_to_menu_pressed() -> void:
	SceneManager.go_to_main_menu()
