extends Node2D
class_name Startup

static var initial_scene:PackedScene = preload("res://core/menu/freeplay/freeplay.tscn")

func _ready() -> void:
	Transition.switch_scene(initial_scene, null)
