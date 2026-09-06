extends Node2D
class_name Startup

static var initial_scene:PackedScene = preload("res://core/menu/title/title.tscn")

func _ready() -> void:
	var scene = initial_scene
	for content in ContentManager.enabled_contents:
		if is_instance_valid(content.initial_scene):
			scene = content.initial_scene
			break
	Transition.switch_scene(scene, null)
