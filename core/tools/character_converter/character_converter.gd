extends Control

var data_path:String = ""
var folder_path:String = ""

func _on_select_data_button_pressed() -> void:
	$data_select_dialog.visible = true

func _on_data_select_dialog_file_selected(path:String) -> void:
	%data_path_label.text = path
	data_path = path

func _on_select_folder_button_pressed() -> void:
	$folder_select_dialog.visible = true

func _on_folder_select_dialog_dir_selected(dir:String) -> void:
	%folder_path_label.text = dir
	folder_path = dir


func _on_save_button_pressed() -> void:
	$saved_label.visible = true
	if !FileAccess.file_exists(data_path) or !DirAccess.dir_exists_absolute(folder_path):
		$saved_label.text = "Invalid path or directory"
		return
	
	var type:String = "V-Slice"
	var raw:String = FileAccess.get_file_as_string(data_path)
	var character_scene = Character.new()
	character_scene.name = _get_file_key(data_path)
	if raw.contains("codename-engine-character>"):
		type = "Codename"
		var parser = XMLParser.new()
		parser.open(data_path)
		_convert_codename(character_scene, parser)
	else:
		if raw.contains("version") and raw.contains("name"):
			_convert_vslice(character_scene, JSON.parse_string(raw))
		else:
			_convert_psych(character_scene, JSON.parse_string(raw))
	
	var packed = PackedScene.new()
	packed.pack(character_scene)
	ResourceSaver.save(packed, folder_path.path_join("character.tscn"))
	$saved_label.text = "Finished converting character from %s format." % type

# CONVERTER SHIT
func _convert_vslice(scene:Character, json:Dictionary):
	var sprite:Node2D
	match json.get("renderType", "sparrow"):
		"sparrow", "multiSparrow":
			sprite = AnimatedSprite2DEx.new()
			sprite.name = "sprite"
			scene.add_child(sprite)
			sprite.owner = scene
			
			sprite.sprite_frames = load(folder_path.path_join(_get_file_key(json.assetPath)) + ".xml")
			sprite.position = Vector2(json.get("offsets", [0, 0])[0], json.get("offsets", [0, 0])[1])
			sprite.scale = Vector2(json.get("scale", 1), json.get("scale", 1))
			sprite.scale = Vector2(json.get("scale", 1), json.get("scale", 1))
	
	var camera_offset = Node2D.new()
	camera_offset.name = "camera_offset"
	scene.add_child(camera_offset)
	camera_offset.owner = scene
	scene.camera_offset = camera_offset
	camera_offset.position = Vector2(json.get("cameraOffsets", [0, 0])[0], json.get("cameraOffsets", [0, 0])[1])
	
	var animation_player = AnimationPlayer.new()
	animation_player.name = "animation_player"
	scene.add_child(animation_player)
	scene.animation_player = animation_player
	animation_player.owner = scene
	
	var library:AnimationLibrary = AnimationLibrary.new()
	
	for origin_anim in json.animations:
		var anim_name:String = origin_anim.name
		if anim_name.begins_with("sing"):
			anim_name = anim_name.to_lower().replace("sing", "sing_").replace("miss", "_miss").replace("-alt", "_alt")
		
		var anim:Animation = Animation.new()
		anim.length = 0.6
		
		if json.get("renderType", "sparrow") == "sparrow" or json.get("renderType", "sparrow") == "multiSparrow":
			var playing_track:int = anim.add_track(Animation.TYPE_VALUE)
			anim.track_set_path(playing_track, "sprite:playing")
			anim.track_insert_key(playing_track, 0.0, true)
			
			var anim_track:int = anim.add_track(Animation.TYPE_VALUE)
			anim.track_set_path(anim_track, "sprite:animation")
			anim.track_insert_key(anim_track, 0.0, origin_anim.prefix)
		
		var offset_track:int = anim.add_track(Animation.TYPE_VALUE)
		anim.track_set_path(offset_track, "sprite:offset")
		anim.track_insert_key(offset_track, 0.0, Vector2(origin_anim.offsets[0], origin_anim.offsets[1]))
		
		library.add_animation(anim_name, anim)
	
	animation_player.add_animation_library(&"", library)
func _convert_psych(scene:Character, json:Dictionary):
	pass
func _convert_codename(scene:Character, xml:XMLParser):
	pass

# simple func
func _get_file_key(path:String) -> String:
	return path.split("/")[path.split("/").size() - 1].split(".")[0]
