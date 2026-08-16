extends Node

var autoloads:Array[Node] = []

func _ready() -> void:
	reload()

func reload() -> void:
	for autoload in autoloads:
		autoload.free()
	autoloads.clear()
	
	for scr in ContentManager.list_content_paths("autoload"):
		if ContentManager.get_content_path("autoload/" + scr).begins_with("res://core/"):
			continue
		var script = load(ContentManager.get_content_path("autoload/" + scr)).new()
		script.name = scr.split(".")[0]
		autoloads.push_back(script)
		get_tree().root.add_child.call_deferred(script)

func get_autoload(id:String) -> Node:
	for autoload in autoloads:
		if autoload.name == id:
			return autoload
	return null
