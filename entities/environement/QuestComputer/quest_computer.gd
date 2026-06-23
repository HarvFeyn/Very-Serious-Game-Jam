extends Node2D

@onready var quest1: Label = $VBoxContainer/Quest1
@onready var quest2: Label = $VBoxContainer/Quest2
@onready var quest3: Label = $VBoxContainer/Quest3

func _ready() -> void:
	quest1.add_theme_color_override("font_color", GameColors.MATRIX_COLOR)
	quest2.add_theme_color_override("font_color", GameColors.MATRIX_COLOR)
	quest3.add_theme_color_override("font_color", GameColors.MATRIX_COLOR)
