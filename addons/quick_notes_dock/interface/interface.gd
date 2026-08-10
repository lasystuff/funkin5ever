@tool class_name QuickNotesDock extends Panel

@onready var edit_tabs: TabContainer = %EditTabs
@onready var editor_theme = EditorInterface.get_editor_theme()
@onready var settings = EditorInterface.get_editor_settings()
@onready var tab_edit: TextEdit = %Edit
@onready var tab_preview: RichTextLabel = %Preview
@onready var save: Button = %Save
@onready var show_in_file_system: Button = %ShowInFileSystem
@onready var tool_bar: HBoxContainer = %ToolBar

@onready var plugin: QuickNotesEditorPlugin:
	set(v):
		if is_instance_valid(v):
			plugin = v
			plugin_supplied.emit()

signal plugin_supplied

var is_from_plugin: bool


func _ready() -> void:
	if !is_from_plugin: return
	for i in edit_tabs.get_child_count():
		match edit_tabs.get_child(i).name:
			&"Edit":
				edit_tabs.set_tab_icon(i, editor_theme.get_icon(&"Edit", &"EditorIcons"))
			&"Preview":
				edit_tabs.set_tab_icon(i, editor_theme.get_icon(&"GuiVisibilityVisible", &"EditorIcons"))

	save.icon = editor_theme.get_icon(&"Save", &"EditorIcons")
	show_in_file_system.icon = editor_theme.get_icon(&"ShowInFileSystem", &"EditorIcons")
	settings.settings_changed.connect(_setting_changed)
	var mono := FontFile.new()
	mono.load_dynamic_font(settings.get_setting("interface/editor/code_font"))
	tab_preview.add_theme_font_override(&"mono_font", mono)
	tab_edit.add_theme_font_override(&"font", mono)
	var file = FileAccess.open(get_setting("defaults/default_path"), FileAccess.READ)
	edit_tabs.current_tab = get_setting("defaults/default_tab")
	tab_edit.text = file.get_as_text()
	_update_text(file.get_as_text())
	print("the file's text: ", file.get_as_text())


	_update_gutter()
	await get_tree().process_frame
	_setting_changed()

func _setting_changed() -> void:
	if settings.get_setting("interface/editor/dock_tab_style"):
		var parent = get_parent()
		if parent is TabContainer:
			parent.set_tab_icon(get_index(), preload("uid://dpq7d22ylxs3o"))

func _update_gutter() -> void:
	var lines := tab_edit.text.split("\n")
	if tab_edit.text.contains("- [ ]") or tab_edit.text.contains("- [x]"):
		if tab_edit.get_gutter_count() == 0:
			tab_edit.add_gutter()
			tab_edit.set_gutter_clickable(0, true)
			tab_edit.set_gutter_type(0, TextEdit.GUTTER_TYPE_ICON)
	elif tab_edit.get_gutter_count() > 0:
		tab_edit.remove_gutter(0)
	if tab_edit.get_gutter_count() == 0: return
	for i in lines.size():
		var line := lines[i]
		var stripped := lines[i].lstrip(" \t")
		if stripped.begins_with("- [ ]"):
			var img := editor_theme.get_icon(&"unchecked", &"CheckBox")
			tab_edit.set_line_gutter_clickable(i, 0, true)
			tab_edit.set_line_gutter_icon(i, 0, img)
		elif stripped.begins_with("- [x]"):
			var img := editor_theme.get_icon(&"checked", &"CheckBox")
			tab_edit.set_line_gutter_clickable(i, 0, true)
			tab_edit.set_line_gutter_icon(i, 0, img)
		else:
			tab_edit.set_line_gutter_clickable(i, 0, false)
			tab_edit.set_line_gutter_icon(i, 0, null)

func _update_text(txt: String, change_edit_text: bool = false) -> void:
	tab_preview.text = ""
	if change_edit_text: tab_edit.text = txt
	if txt.is_empty():
		tab_preview.text = tab_edit.placeholder_text
	var lines := txt.split("\n")
	for i in lines.size():
		var line := lines[i]
		var stripped := lines[i].lstrip(" \t")
		var tabs := "\t".repeat(line.length() - stripped.length())
		if stripped.begins_with("- [ ]") or stripped.begins_with("- [x]"):
			tab_preview.push_meta(i, RichTextLabel.META_UNDERLINE_NEVER, "Toggle checkbox")
			if stripped.begins_with("- [ ]"):
				var img := editor_theme.get_icon(&"unchecked", &"CheckBox")
				tab_preview.add_text(tabs)
				tab_preview.add_image(img)
				tab_preview.append_text(stripped.trim_prefix("- [ ]"))
			elif stripped.begins_with("- [x]"):
				var img := editor_theme.get_icon(&"checked", &"CheckBox")
				tab_preview.add_text(tabs)
				tab_preview.add_image(img)
				if get_setting("checkboxes/grey_out_completed"): tab_preview.push_color(Color(tab_preview.get_theme_color(&"default_color"), .5))
				if get_setting("checkboxes/cross_out_completed"): tab_preview.push_strikethrough()
				tab_preview.append_text(stripped.trim_prefix("- [x]"))
				if get_setting("checkboxes/cross_out_completed"): tab_preview.pop()
				if get_setting("checkboxes/grey_out_completed"): tab_preview.pop()
			tab_preview.pop()
		elif stripped.begins_with("-"):
			tab_preview.append_text(tabs + get_setting("formatting/bullet_point_text") + " " + stripped.trim_prefix("-").trim_prefix(" "))
		else:
			tab_preview.append_text(line)
		tab_preview.newline()

func get_setting(s: String) -> Variant:
	return settings.get_setting("plugin/quick_notes/" + s)


func _on_save_pressed() -> void:
	plugin.save()
	%ToastMessage.toast("Saved to %s" % String(get_setting("defaults/default_path")).get_file())

func _on_edit_gutter_clicked(line: int, gutter: int) -> void:
	toggle_line(line)

func toggle_line(idx: int) -> void:
	var txt := tab_edit.text
	var result: String
	var line_count := txt.get_slice_count("\n")
	for i in line_count:
		var line := txt.get_slice("\n", i)
		var stripped := line.lstrip(" \t")
		var tabs := "\t".repeat(line.length() - stripped.length())
		if idx == i:
			if stripped.begins_with("- [ ]"):
				stripped = "- [x]" + stripped.trim_prefix("- [ ]")
			elif stripped.begins_with("- [x]"):
				stripped = "- [ ]" + stripped.trim_prefix("- [x]")
		result += tabs + stripped + ("\n" if i != line_count - 1 else "")
	_update_text(result, true)
	_update_gutter()

func _on_preview_meta_clicked(meta: Variant) -> void:
	toggle_line(meta as int)


func _on_edit_tabs_tab_changed(tab: int) -> void:
	if !is_node_ready(): await ready
	if tab == 0:
		_update_gutter()
	else:
		_update_text(tab_edit.text)

func _on_show_in_file_system_pressed() -> void:
	EditorInterface.get_file_system_dock().navigate_to_path(get_setting("defaults/default_path"))


func _on_edit_text_changed() -> void:
	_update_gutter()
