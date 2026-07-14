extends Node
const CORE_DIRECTORY:String = "res://core/"
const CONTENTS_DIRECTORY:String = "res://contents/"

var contents:Array[ContentMetadata] = []
var enabled_contents:Array[ContentMetadata]:
	get():
		return contents.filter(func(c): return c.enabled)
var current_content:String = "_core"

var reference_content = ContentMetadata.new()

func _init() -> void:
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
		for save in SaveData.data.content_list:
			if save.id == a.id:
				a_index = SaveData.data.content_list.find(save)
				a.enabled = save.enabled
			elif save.id == b.id:
				b_index = SaveData.data.content_list.find(save)
				b.enabled = save.enabled
		return true
	)
	
func get_current_content():
	var filtered = contents.filter(func(c): return c.id == current_content)
	if filtered.size() < 1:
		return null
	return filtered[0]

func get_content_path(path:String) -> String:
	# load from current content
	if get_current_content() != null:
		var p = get_current_content().content_path.path_join(path)
		if _folder_or_resource_exists(p):
			return p
	# load from global content
	for content in enabled_contents:
		if !content.global: continue
		var p = content.content_path.path_join(path)
		if _folder_or_resource_exists(p):
			return p
	# return core file
	return CORE_DIRECTORY.path_join(path)

func list_content_paths(path:String, every:bool = false) -> Array:
	var result = Array(ResourceLoader.list_directory(CORE_DIRECTORY.path_join(path)))
	
	for content in enabled_contents:
		if !every && content.id != current_content && !content.global:
			continue
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
