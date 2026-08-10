extends Node2D

const DEFAULT_SONG_LIST:Array[String] = []

static var current_item:int = 0
var controllable:bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for song in DEFAULT_SONG_LIST:
		create_song(song, "_core")
	
	for content in ContentManager.enabled_contents:
		for song in content.freeplay_song_list:
			create_song(song, content.id)
	change_item(current_item, true)

func change_item(change:int = 0, first:bool = false) -> void:
	%camera.position_smoothing_enabled = !first
	current_item = wrap(current_item + change, 0, %songs.get_child_count())
	%camera.global_position.y = %songs.get_child(current_item).global_position.y
	GlobalSound.play_sfx(preload("res://core/menu/scroll.ogg"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_up") && controllable:
		change_item(-1)
	elif Input.is_action_just_pressed("ui_down") && controllable:
		change_item(1)
	elif Input.is_action_just_pressed("ui_accept") && controllable:
		controllable = false
		ContentManager.current_content = %songs.get_child(current_item).content_id
		
		GlobalSound.play_sfx(preload("res://core/menu/confirm.ogg"))

		Song.game_mode = Song.GameMode.FREEPLAY
		Song.return_scene = load(self.scene_file_path)
		
		Song.start_playlist([%songs.get_child(current_item).song_id])
	elif Input.is_action_just_pressed("ui_mod_manager") && controllable:
		controllable = false
		Transition.switch_scene(load("res://core/menu/contents_menu/contents_menu.tscn"))
	
	for item in %songs.get_children():
		item.modulate.a = 1 if item.get_index() == current_item else 0.5

func create_song(song:String, content:String) -> void:
	var item = load("res://core/menu/freeplay/song_item.tscn").instantiate()
	item.content_id = content
	item.song_id = song
	%songs.add_child(item)
