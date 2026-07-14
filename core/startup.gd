extends Node2D
class_name Startup

static var initial_scene:PackedScene = preload("res://core/menu/freeplay/freeplay.tscn")

static var scripted_autoloads:Array[Node] = []

func _ready() -> void:
	CustomAutoload.reload()
	
	Transition.switch_scene(initial_scene, null)
