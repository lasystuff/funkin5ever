@tool class_name QuickNotesSyntaxHighligher extends SyntaxHighlighter

var settings := EditorInterface.get_editor_settings()

func _get_line_syntax_highlighting(line: int) -> Dictionary:
	var stripped_line = get_text_edit().text.get_slice("\n", line).lstrip(" 	")
	var start_idx = get_text_edit().text.get_slice("\n", line).length() - stripped_line.length()
	if stripped_line.begins_with("- [ ]"):
		return {start_idx: {"color": settings.get_setting("interface/theme/accent_color")}, start_idx + 5: {"color": get_text_edit().get_theme_color("font_color")}}
	elif stripped_line.begins_with("- [x]"):
		return {start_idx: {"color": Color(get_text_edit().get_theme_color("font_color"), 0.5)}}
	elif stripped_line.begins_with("-"):
		return {start_idx: {"color": Color(get_text_edit().get_theme_color("font_color"), 0.75)}, start_idx + 1: {"color": get_text_edit().get_theme_color("font_color")}}
	return {}
