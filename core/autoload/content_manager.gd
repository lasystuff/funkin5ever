extends Node
const CORE_DIRECTORY:String = "res://core/"
var PACKED_CONTENTS_DIRECTORY:String = OS.get_executable_path().get_base_dir().path_join("contents/")
const CONTENTS_DIRECTORY:String = "res://contents/"

var contents:Array[ContentMetadata] = []
var enabled_contents:Array[ContentMetadata]:
	get():
		return contents.filter(func(c): return c.enabled)

var reference_content = ContentMetadata.new()

func _init() -> void:
	# load mod zip/pck files
	if OS.has_feature("template"):
		# show warning
		if not DirAccess.dir_exists_absolute(PACKED_CONTENTS_DIRECTORY):
			DirAccess.make_dir_recursive_absolute(PACKED_CONTENTS_DIRECTORY)
		else:
			if DirAccess.get_directories_at(PACKED_CONTENTS_DIRECTORY).size() > 0:
				var popup:AcceptDialog = AcceptDialog.new()
				popup.dialog_text = "If you wish to run mods with this engine, they will not launch if they are in folder format.\nPlease place them in the `contents/` directory as .zip or .pck files."
				popup.force_native = true
				popup.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
				popup.process_mode = Node.PROCESS_MODE_ALWAYS

				popup.confirmed.connect(func():
					popup.queue_free()
				)
				
				add_child(popup)
				popup.visible = true
			
			for file in DirAccess.get_files_at(PACKED_CONTENTS_DIRECTORY):
				if file.ends_with(".pck") or file.ends_with(".zip"):
					ProjectSettings.load_resource_pack(PACKED_CONTENTS_DIRECTORY.path_join(file))
	
	for folder in ResourceLoader.list_directory(CONTENTS_DIRECTORY):
		if folder.ends_with("/"):
			if ResourceLoader.exists(CONTENTS_DIRECTORY.path_join(folder + "content.tres")):
				var content_data:ContentMetadata = load(CONTENTS_DIRECTORY.path_join(folder + "content.tres"))
				content_data.id = folder.substr(0, folder.length() - 1)
				content_data.content_path = CONTENTS_DIRECTORY.path_join(folder)
				contents.push_back(content_data)
				print("Loaded content: " + content_data.name)
	
	contents.sort_custom(func(a:ContentMetadata, b:ContentMetadata):
		var a_index:int = 999
		var b_index:int = 1000
		var list = Config.get_config("content_list")
		for save in list:
			if save.id == a.id:
				a_index = list.find(save)
				a.enabled = save.enabled
			elif save.id == b.id:
				b_index = list.find(save)
				b.enabled = save.enabled
		if a_index < b_index:
			return true
		return false
	)
	
	reload_window.call_deferred()

func get_content_path(path:String) -> String:
	# load from current content
	for content in enabled_contents:
		var p = content.content_path.path_join(path)
		if _folder_or_resource_exists(p):
			return p
	# return core file
	return CORE_DIRECTORY.path_join(path)

func list_content_paths(path:String) -> Array:
	var result = Array(ResourceLoader.list_directory(CORE_DIRECTORY.path_join(path)))
	
	for content in enabled_contents:
		var p = content.content_path.path_join(path)
		for file in Array(ResourceLoader.list_directory(p)):
			if !result.has(file):
				result.push_back(file)
	return result

func _folder_or_resource_exists(p:String) -> bool:
	return DirAccess.dir_exists_absolute(p) or ResourceLoader.exists(p)

func create_list_save() -> Array[Dictionary]:
	var result:Array[Dictionary] = []
	for content in contents:
		result.push_back({"id": content.id, "enabled": content.enabled})
	return result

func reload_window() -> void:
	#await get_tree().create_timer(2).timeout
	for content in enabled_contents:
		if !content.window_title.is_empty():
			DisplayServer.window_set_title(content.window_title)
			if is_instance_valid(content.icon):
				DisplayServer.set_icon(content.icon.get_image())
			break
