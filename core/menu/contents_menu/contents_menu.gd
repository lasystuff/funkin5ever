extends Node2D

const DEFAULT_SONG_LIST:Array[String] = []

var current_item:int = 0

var bgs:Dictionary

var controllable:bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ContentManager.current_content = ""
	
	for content in ContentManager.contents:
		create_content(content)
	change_item(0, true)

func change_item(change:int = 0, first:bool = false) -> void:
	%camera.position_smoothing_enabled = !first
	current_item = wrap(current_item + change, 0, %contents.get_child_count())
	%camera.global_position.y = %contents.get_child(current_item).global_position.y
	GlobalSound.play_sfx(preload("res://core/menu/scroll.ogg"))
	
	var current_item = %contents.get_child(current_item)
	%title_label.text = current_item.content.name
	%description_label.text = current_item.content.description if current_item.content.description.length() > 0 else "no description provided"
	%icon.texture = load(current_item.content.content_path.path_join("menu/contents_menu/icon.png")) if FileAccess.file_exists(current_item.content.content_path.path_join("menu/contents_menu/icon.png")) else load("res://core/menu/contents_menu/icon.png")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_up") && controllable:
		change_item(-1)
	elif Input.is_action_just_pressed("ui_down") && controllable:
		change_item(1)
	elif Input.is_action_just_pressed("ui_accept") && controllable:
		%contents.get_child(current_item).button_pressed = !%contents.get_child(current_item).button_pressed
	elif Input.is_action_just_pressed("ui_cancel") && controllable:
		controllable = false
		
		var has_global:bool = false
		ContentManager.contents.clear()
		for item in $contents.get_children():
			if item.content.enabled && item.content.global:
				has_global = true
			ContentManager.contents.push_back(item.content)
		
		if has_global:
			Transition.switch_scene(preload("res://core/startup.tscn"))
		else:
			CustomAutoload.reload()
			Transition.switch_scene(preload("res://core/menu/freeplay/freeplay.tscn"))
	
	for item in %contents.get_children():
		item.modulate.a = 1 if item.get_index() == current_item else 0.8

func create_content(content:ContentMetadata) -> void:
	var item = load("res://core/menu/contents_menu/content_capsule.tscn").instantiate()
	item.setup(content)
	%contents.add_child(item)


func _on_sort_up_button_pressed() -> void:
	GlobalSound.play_sfx(preload("res://core/menu/scroll.ogg"))
	var index = wrap(%contents.get_child(current_item).get_index() - 1, 0, %contents.get_child_count())
	%contents.move_child(%contents.get_child(current_item), index)
	change_item.call_deferred(-1)

func _on_sort_down_button_pressed() -> void:
	GlobalSound.play_sfx(preload("res://core/menu/scroll.ogg"))
	var index = wrap(%contents.get_child(current_item).get_index() + 1, 0, %contents.get_child_count())
	%contents.move_child(%contents.get_child(current_item), index)
	change_item.call_deferred(1)
