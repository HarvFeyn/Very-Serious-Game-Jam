@tool
extends EditorScript

func _run() -> void:
	var theme: Theme = Theme.new()
	
	theme.set_color("font_color", "Button", GameColors.WHITE)
	theme.set_color("font_hover_color", "Button", GameColors.ACCENT)
	theme.set_color("font_pressed_color", "Button", GameColors.UI_COLOR_PRIMARY)
	
	for state: String in ["normal", "hover", "pressed", "focus", "disabled"]:
		var style: StyleBoxFlat = StyleBoxFlat.new()
		style.bg_color = GameColors.UI_COLOR_PRIMARY
		style.corner_radius_bottom_left = 3
		style.corner_radius_bottom_right = 3
		style.corner_radius_top_left = 3
		style.corner_radius_top_right = 3
		style.border_color = GameColors.UI_COLOR_SECONDARY
		style.border_width_bottom = 1
		style.border_width_left = 1
		style.border_width_right = 1
		style.border_width_top = 1
		style.expand_margin_bottom = 7
		style.expand_margin_top = 7
		style.expand_margin_right = 7
		style.expand_margin_left = 7
		
		theme.set_stylebox(state, "Button", style)
		
	ResourceSaver.save(theme, "res://shared/themes/global_theme.tres")
