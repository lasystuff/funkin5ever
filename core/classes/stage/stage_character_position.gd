@tool
extends Node2D
class_name StageCharacterPosition

@export var is_player:bool = false:
	set(value):
		is_player = value
		_flip_preview()
@export var preview_character:PackedScene = preload("res://core/gameplay/characters/bf/character.tscn"):
	set(value):
		preview_character = value
		_reload_preview()
		
var _preview_instance:Character
var _original_scale:float = 1

func _init() -> void:
	_reload_preview()
	_flip_preview()

func _reload_preview() -> void:
	if !Engine.is_editor_hint():
		return
	var instance = preview_character.instantiate()
	if is_instance_valid(_preview_instance):
		_preview_instance.queue_free()
	_preview_instance = instance
	_original_scale = _preview_instance.scale.x
	add_child(instance)
	
	_flip_preview()

func _flip_preview() -> void:
	if !Engine.is_editor_hint():
		return
	if is_player:
		if !_preview_instance.facing_left:
			_preview_instance.scale.x = _original_scale * -1
		else:
			_preview_instance.scale.x = _original_scale
	else:
		if _preview_instance.facing_left:
			_preview_instance.scale.x = _original_scale * -1
		else:
			_preview_instance.scale.x = _original_scale
