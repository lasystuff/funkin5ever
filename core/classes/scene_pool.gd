extends Node
class_name ScenePool

var scene:PackedScene
var pool:Array = []

func _init(_scene:PackedScene) -> void:
	scene = _scene

func get_object() -> Node:
	if pool.size() > 0:
		var target = pool[0]
		target.process_mode = Node.ProcessMode.PROCESS_MODE_INHERIT
		pool.erase(target)
		return target
	return scene.instantiate()

func add_to_pool(object:Node) -> void:
	object.get_parent().remove_child(object)
	object.process_mode = Node.PROCESS_MODE_DISABLED
	pool.push_back(object)
