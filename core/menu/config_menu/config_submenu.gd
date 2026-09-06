extends Node2D
class_name ConfigSubMenu

@export_file_path(".tscn") var back_scene_path:String

var current_item:int = 0
var controllable:bool = true

@export var item_container:Container
@export var camera:Camera2D
@export var hint_label:Label

func _ready() -> void:
	change_item()

func change_item(change:int = 0) -> void:
	current_item = wrap(current_item + change, 0, item_container.get_child_count())
	camera.global_position.y = item_container.get_child(current_item).global_position.y
	GlobalSound.play_sfx(preload("res://core/menu/scroll.ogg"))
	if is_instance_valid(hint_label):
		hint_label.visible = !(item_container.get_child(current_item) as ConfigItem).hint.is_empty()
		hint_label.text = (item_container.get_child(current_item) as ConfigItem).hint

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_up") && controllable:
		change_item(-1)
	elif Input.is_action_just_pressed("ui_down") && controllable:
		change_item(1)
	elif Input.is_action_just_pressed("ui_accept") && controllable:
		# we are not doing stuff here
		GlobalSound.play_sfx(preload("res://core/menu/confirm.ogg"))
	elif Input.is_action_just_pressed("ui_cancel") && controllable:
		controllable = false
		Config.save_config()
		if back_scene_path.is_empty():
			Transition.switch_scene(load("res://core/menu/config_menu/main_config.tscn"))
		else:
			Transition.switch_scene(load(back_scene_path))
	
	for item in item_container.get_children():
		(item as ConfigItem).selected = item.get_index() == current_item
		item.modulate.a = 1.0 if (item as ConfigItem).selected else 0.5
