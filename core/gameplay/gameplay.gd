extends Node2D
class_name Gameplay

enum GameMode
{
	STORY,
	FREEPLAY,
	CHARTING
}

static var instance:Gameplay
static var playlist:Array[Chart] = []

static var story_stats:GameStats = GameStats.new()
static var game_mode:GameMode = GameMode.FREEPLAY
static var return_scene:PackedScene = load("res://core/menu/freeplay/freeplay.tscn")

var pause_scene:PackedScene = load("res://core/gameplay/pause_screen.tscn")

var chart:Chart:
	get():
		return playlist[0]
var metadata:SongMetadata
var events:Array[EventData]

var stats:GameStats = GameStats.new()

var conductor:Conductor
var hud:HUD

var stage:Stage

var player:Character
var opponent:Character
var spectator:Character

var hud_scene:PackedScene = load("res://core/gameplay/hud/default.tscn")
var countdown_skin:CountdownSkin = load("res://core/gameplay/countdown/default/skin.tres")

var camera_bop_interval:int = 4
var camera_bop_mult:float = 1
var camera_bop_add:float = 0
var camera_position:Node2D = Node2D.new()
var camera_position_offset:Node2D = Node2D.new()
var camera_zoom_mult:float = 1
var camera_offset_scale:float = 10

var scripts:Array[GameScript] = []
var event_scripts:Dictionary[String, EventScript] = {}
var note_type_scripts:Dictionary[String, GameScript] = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instance = self
	
	metadata = SongMetadata.get_from_id(chart._song_id)
	events = chart.events.duplicate_deep(0)
	
	conductor = Conductor.new()
	add_child(conductor)
	conductor.beat_hit.connect(_on_beat_hit)
	conductor.set_bpm_changes(chart.bpm_changes)
	
	
	var song_folder = ContentManager.get_content_path("gameplay/songs/" + chart._song_id)
	for stream in ResourceLoader.list_directory(song_folder):
		if !stream.ends_with(".ogg"):
			continue
		var audio_player = AudioStreamPlayer.new()
		audio_player.stream = load(song_folder.path_join(stream))
		%audio.add_child(audio_player)
	
	if %audio.get_child_count() > 0:
		%audio.get_child(0).finished.connect(_song_finished)
		
	# LOAD SCRIPTS
	
	# song-specific scripts
	for scr in ContentManager.list_content_paths("gameplay/songs/" + chart._song_id + "/scripts"):
		var script = load(ContentManager.get_content_path("gameplay/songs/" + chart._song_id + "/scripts/" + scr)).new()
		scripts.push_back(script)
	# global scripts
	for scr in ContentManager.list_content_paths("gameplay/scripts"):
		var script = load(ContentManager.get_content_path("gameplay/scripts/" + scr)).new()
		scripts.push_back(script)
		script._ready()
	
	# event scripts
	for event in events:
		if !event_scripts.has(event.type):
			var script_path = ContentManager.get_content_path("gameplay/events/" + event.type + ".gd")
			if ResourceLoader.exists(script_path):
				var script = load(script_path).new()
				event_scripts.set(event.type, script)
				scripts.push_back(script)
				script._ready()
				script._on_event_preload(event)
		else:
			event_scripts.get(event.type)._on_event_preload(event)
			
	# note-type scripts
	for note in chart.notes:
		if note.type != "" && !note_type_scripts.has(note.type):
			var script_path = ContentManager.get_content_path("gameplay/events/" + note.type + ".gd")
			if ResourceLoader.exists(script_path):
				var script = load(script_path).new()
				note_type_scripts.set(note.type, script)
				scripts.push_back(script)
				script._ready()
	
	var stage_path = ContentManager.get_content_path("gameplay/stages/" + chart.stage)
	if !DirAccess.dir_exists_absolute(stage_path): stage_path = ContentManager.get_content_path("gameplay/stages/stage")
	stage = load(stage_path.path_join("stage.tscn")).instantiate()
	add_child(stage)
	
	player = Character.get_instance(chart.player)
	stage.add_character(player, Stage.CharacterType.PLAYER)
	if !player.facing_left: player.flip_character()
	
	opponent = Character.get_instance(chart.opponent)
	stage.add_character(opponent, Stage.CharacterType.OPPONENT)
	if opponent.facing_left: opponent.flip_character()
	
	spectator = Character.get_instance(chart.spectator)
	stage.add_character(spectator, Stage.CharacterType.SPECTATOR)
	if spectator.facing_left: spectator.flip_character()
	
	camera_position.position = lerp(player.get_camera_pos(), opponent.get_camera_pos(), 0.5)
	
	hud = hud_scene.instantiate()
	$hud_layer.add_child(hud)

	hud.player_strumline.scroll_speed = chart.scroll_speed
	hud.player_strumline.note_hit.connect(_player_note_hit)
	hud.player_strumline.note_miss.connect(_player_note_miss)
	hud.opponent_strumline.scroll_speed = chart.scroll_speed
	hud.opponent_strumline.note_hit.connect(_opponent_note_hit)
	
	for note in chart.notes:
		match note.player:
			NoteData.PlayerType.PLAYER:
				hud.player_strumline.note_queues.push_back(note)
			NoteData.PlayerType.OPPONENT:
				hud.opponent_strumline.note_queues.push_back(note)
	
	for script in scripts:
		script._ready_post()
	hud._ready_post()
	stage._ready_post()
	start_countdown()

var current_countdown:int = 0
func start_countdown() -> void:
	conductor.song_position = -Conductor.instance.get_crotchet() * 5
	
	for event in events:
		if event.time < 0.001 && event_scripts.has(event.type) && event_scripts.get(event.type)._call_before_countdown():
			for script in scripts:
				script._on_event_call(event)
			events.erase(event)
	
	%countdown.scale = Vector2(countdown_skin.scale, countdown_skin.scale)
	
	var countdown_timer:Timer = Timer.new()
	add_child(countdown_timer)
	countdown_timer.timeout.connect(func():
		match current_countdown:
			0: # three
				%countdown.visible = (countdown_skin.on_your_mark_texture != null)
				%countdown.texture = countdown_skin.on_your_mark_texture
				%countdown_audio.stream = countdown_skin.on_your_mark_sound
				%countdown_audio.play()
			1: # two
				%countdown.visible = (countdown_skin.ready_texture != null)
				%countdown.texture = countdown_skin.ready_texture
				%countdown_audio.stream = countdown_skin.ready_sound
				%countdown_audio.play()
			2: # one
				%countdown.visible = (countdown_skin.set_texture != null)
				%countdown.texture = countdown_skin.set_texture
				%countdown_audio.stream = countdown_skin.set_sound
				%countdown_audio.play()
			3: # GO
				%countdown.visible = (countdown_skin.go_texture != null)
				%countdown.texture = countdown_skin.go_texture
				%countdown_audio.stream = countdown_skin.go_sound
				%countdown_audio.play()
			4: # song start
				%countdown.visible = false
				countdown_timer.stop()
				countdown_timer.queue_free()
				for audio in %audio.get_children(): audio.play()
				for script in scripts:
					script._on_song_start()
				stage._on_song_start()
				hud._on_song_start()
		if current_countdown <= 3:
			for script in scripts:
				script._on_countdown_beat(current_countdown)
			stage._on_countdown_beat(current_countdown)
		current_countdown += 1
	)
	countdown_timer.start(conductor.get_crotchet())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !%audio.get_children()[0].playing:
		conductor.song_position += delta
	else:
		var inst_time:float = (%audio.get_children()[0].get_playback_position() + AudioServer.get_time_since_last_mix() )
		conductor.song_position = inst_time
		
		for event in events:
			if event.time <= conductor.song_position:
				for script in scripts:
					script._on_event_call(event)
				stage._on_event_call(event)
				hud._on_event_call(event)
				events.erase(event)
	
	for script in scripts:
		script._process(delta)
	
	camera_bop_add = lerpf(0, camera_bop_add, exp(-delta * 3.125))
	hud.scale = Vector2(1 + camera_bop_add, 1 + camera_bop_add)
	%camera.position = camera_position.position + camera_position_offset.position
	%camera.zoom.x = (stage.zoom * camera_zoom_mult) + camera_bop_add
	%camera.zoom.y = %camera.zoom.x
	
	if Input.is_action_just_pressed("ui_pause"):
		var pause = pause_scene.instantiate()
		add_child(pause)
		get_tree().paused = true

func _on_beat_hit(beat:int) -> void:
	if beat % camera_bop_interval == 0:
		camera_bop_add = 0.02 * camera_bop_mult
		
func _player_note_hit(note:Note, is_sustain_part:bool) -> void:
	player.play_anim(note.sing_animations[note.data.column], true)
	if !is_sustain_part:
		move_camera_offset(note.data.column)
		var judge = stats.score_note(note)
		for script in scripts:
			script._on_note_hit(note, note.strumline, judge)
		hud._on_note_hit(note, note.strumline, judge)
		stage._on_note_hit(note, note.strumline, judge)
	
func _player_note_miss(note:Note, type:Strumline.MissType) -> void:
	if player.has_animation(note.sing_animations[note.data.column] + "_miss"):
		player.play_anim(note.sing_animations[note.data.column] + "_miss", true)
	if type == Strumline.MissType.NOTE_MISS:
		stats.miss_note()
		for script in scripts:
			script._on_note_miss(note, note.strumline)
		hud._on_note_miss(note, note.strumline)
		stage._on_note_miss(note, note.strumline)
	
func _opponent_note_hit(note:Note, is_sustain_part:bool) -> void:
	opponent.play_anim(note.sing_animations[note.data.column], true)
	if !is_sustain_part:
		move_camera_offset(note.data.column)
		for script in scripts:
			script._on_note_hit(note, note.strumline)
		hud._on_note_hit(note, note.strumline)
		stage._on_note_hit(note, note.strumline)

var camera_tween:Tween
func move_camera(_pos:Vector2, _speed:float, _trans:Variant = null, _ease:Variant = null):
	if camera_tween != null:
		camera_tween.kill()
	if _speed <= 0:
		camera_position.position = _pos
		return
	
	if _trans == null: _trans = Tween.TransitionType.TRANS_EXPO
	if _ease == null: _ease = Tween.EaseType.EASE_OUT
	
	camera_tween = get_tree().create_tween()
	camera_tween.set_trans(_trans).set_ease(_ease)
	camera_tween.tween_property(camera_position, "position", _pos, _speed)

var flash_tween:Tween
func flash_camera(_speed:float, color:Color = Color.WHITE):
	if flash_tween != null:
		flash_tween.kill()
	
	%flash.modulate.a = 1
	%flash.color = color
	flash_tween = get_tree().create_tween()
	flash_tween.set_trans(Tween.TransitionType.TRANS_CUBIC).set_ease(Tween.EaseType.EASE_OUT)
	flash_tween.tween_property(%flash, "modulate:a", 0, _speed)

var camera_offset_tween:Tween
func move_camera_offset(direction:int):
	var pos = Vector2.ZERO
	match direction:
		0:
			pos = Vector2(-camera_offset_scale, 0)
		1:
			pos = Vector2(0, camera_offset_scale)
		2:
			pos = Vector2(0, -camera_offset_scale)
		3:
			pos = Vector2(camera_offset_scale, 0)
	if camera_offset_tween != null:
		camera_offset_tween.kill()
	
	camera_offset_tween = get_tree().create_tween()
	camera_offset_tween.set_trans(Tween.TransitionType.TRANS_EXPO).set_ease(Tween.EaseType.EASE_OUT)
	camera_offset_tween.tween_property(camera_position_offset, "position", pos, 1.4)

var zoom_tween:Tween
func zoom_camera(_value:float, _speed:float, _trans:Variant = null, _ease:Variant = null):
	if zoom_tween != null:
		zoom_tween.kill()
	if _speed <= 0:
		camera_zoom_mult = _value
		return
	
	if _trans == null: _trans = Tween.TransitionType.TRANS_EXPO
	if _ease == null: _ease = Tween.EaseType.EASE_OUT
	
	zoom_tween = get_tree().create_tween()
	zoom_tween.set_trans(_trans).set_ease(_ease)
	zoom_tween.tween_property(self, "camera_zoom_mult", _value, _speed)
	
func _on_exit() -> void:
	for script in scripts:
		script.queue_free()
		scripts.erase(script)

func _song_finished() -> void:
	for script in scripts:
		script._on_song_finish()
	stage._on_song_finish()
	hud._on_song_finish()
	
	_on_exit()
	match game_mode:
		GameMode.FREEPLAY:
			Transition.switch_scene(return_scene)
		GameMode.STORY:
			if story_stats == null:
				story_stats = GameStats.new()
			if playlist.size() > 1:
				playlist.pop_front()
				Transition.switch_scene(preload("uid://wl54eujibcfj"))
			else:
				story_stats = null
				Transition.switch_scene(return_scene)
	Transition.switch_scene(return_scene)
