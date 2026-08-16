extends Node

var data:ConfigData

func _init() -> void:
	load_config()

func get_config(id:String, default_value:Variant = null) -> Variant:
	if id in data:
		return data.get(id)
	return default_value

func set_config(id:String, value:Variant) -> void:
	if id in data:
		data.set(id, value)

func load_config() -> void:
	if FileAccess.file_exists("user://save"):
		var saved:ConfigData = str_to_var(FileAccess.get_file_as_string("user://save"))
		if saved.version != ConfigData.DEFAULT_CONFIG_VERSION:
			saved.migrate()
		data = saved
	else:
		data = ConfigData.new()
	data._on_load()

func save_config() -> void:
	data._on_save()
	var f = FileAccess.open("user://save", FileAccess.WRITE)
	f.store_string(var_to_str(data))
	f.close()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_config()
