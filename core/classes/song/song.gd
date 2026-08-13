extends Node2D
class_name Song

enum GameMode
{
	STORY,
	FREEPLAY,
	CHARTING
}

static var current:Song
static var playlist:Array[SongMetadata] = []
static var story_stats:GameStats
static var game_mode:GameMode = GameMode.FREEPLAY
static var return_scene:PackedScene

@export var animation_player:AnimationPlayer
@export var scripts:Array[GDScript] = []

@export var skip_countdown:bool = false

@export_category("Character")
@export var player:Character
@export var opponent:Character
@export var spectator:Character

@export_category("Theme")
@export var hud_scene:PackedScene = preload("res://core/gameplay/hud/default.tscn")
@export var countdown_skin:CountdownSkin = preload("res://core/gameplay/countdown/default/skin.tres")
@export var pause_scene:PackedScene = preload("res://core/gameplay/pause_screen.tscn")
@export var death_scene = preload("res://core/gameplay/death/death_screen.tscn")

var camera_bop_interval:int = 4

var conductor:Conductor

var chart:Chart
var meta:SongMetadata:
	get():
		return playlist[0]

var loaded_scripts:Array[SongScript] = []

var hud_layer:CanvasLayer
var hud:HUD

var song_started:bool = false
var stats:GameStats

var player_vocal:SongStreamPlayer

static func start_playlist(_playlist:Array[String]) -> void:
	playlist = []
	for song in _playlist:
		var song_meta:SongMetadata = SongMetadata.get_from_id(song)
		if is_instance_valid(song_meta.scene):
			playlist.push_back(song_meta)
	if playlist.size() > 0:
		Transition.switch_scene(playlist[0].scene)
	else:
		print("[SONG] Playlist is empty, cannot start the game!")

func _init() -> void:
	current = self

func _ready() -> void:
	# fix when trying to run from editor directly
	if playlist.size() < 1:
		var song = self.scene_file_path.split("/")[self.scene_file_path.split("/").size() - 2]
		playlist.push_back(SongMetadata.get_from_id(song))
	
	conductor = Conductor.new()
	add_child(conductor)
	conductor.beat_hit.connect(_on_beat_hit)
	
	chart = Chart.get_from_id(meta._song_id, "normal")
	conductor.set_bpm_changes(chart.bpm_changes)
	
	stats = GameStats.new()
	
	animation_player.animation_finished.connect(func(_n): _song_finished())
	
	for script_file in scripts:
		var instance = script_file.new() as SongScript
		loaded_scripts.push_back(instance)
		instance._ready()
	
	hud_layer = CanvasLayer.new()
	hud = hud_scene.instantiate() as HUD
	hud_layer.add_child(hud)
	add_child(hud_layer)
	
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
	
	if is_instance_valid(animation_player.find_child("player", false)):
		if animation_player.find_child("player", false) is SongStreamPlayer:
			player_vocal = animation_player.find_child("player", false)
	elif is_instance_valid(animation_player.find_child("vocal", false)):
		if animation_player.find_child("vocal", false) is SongStreamPlayer:
			player_vocal = animation_player.find_child("vocal", false)
	
	for script in loaded_scripts:
		script._ready_post()
	hud._ready_post()
	
	_start_countdown()
	
func _start_countdown() -> void:
	if skip_countdown:
		_start_song()
		return
	
	conductor.song_position = -conductor.get_crotchet() * 5
	var countdown:Countdown = preload("res://core/gameplay/countdown/countdown.tscn").instantiate() as Countdown
	countdown.skin = countdown_skin
	hud_layer.add_child(countdown)
	
	countdown.countdown_step.connect(func(step:int):
		if is_instance_valid(player):
			player.beat_hit(step)
		if is_instance_valid(opponent):
			opponent.beat_hit(step)
		if is_instance_valid(spectator):
			spectator.beat_hit(step)
		for script in loaded_scripts:
			script._on_countdown_beat(step)
		hud._on_countdown_beat(step)
	)
	
	countdown.countdown_finished.connect(_start_song)
	
	countdown.start()

func _start_song() -> void:
	animation_player.play("song")
		
	for script in loaded_scripts:
		script._on_song_start()
	hud._on_song_start()
	
	song_started = true

func _player_note_hit(note:Note, is_sustain_part:bool) -> void:
	if is_instance_valid(player): player.play_anim(note.sing_animations[note.data.column], !is_sustain_part)
	if is_instance_valid(player_vocal): player_vocal.volume_linear = 1
	if !is_sustain_part:
		var judge = stats.score_note(note)
		for script in loaded_scripts:
			script._on_note_hit(note, note.strumline, judge)
		hud._on_note_hit(note, note.strumline, judge)
	
func _player_note_miss(note:Note, type:Strumline.MissType) -> void:
	if is_instance_valid(player) && player.has_animation(note.sing_animations[note.data.column] + "_miss"):
		player.play_anim(note.sing_animations[note.data.column] + "_miss", true)
	if is_instance_valid(player_vocal): player_vocal.volume_linear = 0
	if type == Strumline.MissType.NOTE_MISS:
		stats.miss_note()
		for script in loaded_scripts:
			script._on_note_miss(note, note.strumline)
		hud._on_note_miss(note, note.strumline)
	
func _opponent_note_hit(note:Note, is_sustain_part:bool) -> void:
	if is_instance_valid(opponent): opponent.play_anim(note.sing_animations[note.data.column], !is_sustain_part)
	if !is_sustain_part:
		for script in loaded_scripts:
			script._on_note_hit(note, note.strumline)
		hud._on_note_hit(note, note.strumline)
	
func _process(delta: float) -> void:
	if animation_player.is_playing():
		if !song_started:
			song_started = true
		conductor.song_position = animation_player.current_animation_position
	else:
		conductor.song_position += delta
	
	for script in loaded_scripts:
		script._process(delta)
	
	if Input.is_action_just_pressed("ui_pause"):
		var pause = pause_scene.instantiate()
		add_child(pause)
		get_tree().paused = true

	if Input.is_action_just_pressed("debug_kill"):
		stats.health = 0
	
	if stats.health == 0:
		hud_layer.visible = false
		var death = death_scene.instantiate()
		add_child(death)
		get_tree().paused = true

var zoom_tween:Tween
func _on_beat_hit(beat:int) -> void:
	if beat % camera_bop_interval == 0:
		if is_instance_valid(zoom_tween):
			zoom_tween.kill()
		hud.scale += Vector2(0.02, 0.02)
		zoom_tween = get_tree().create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		zoom_tween.tween_property(hud, "scale", Vector2.ONE, conductor.get_crotchet() * camera_bop_interval)

func _on_exit() -> void:
	for script in loaded_scripts:
		script.queue_free()
		loaded_scripts.erase(script)

func _song_finished() -> void:
	for script in loaded_scripts:
		script._on_song_finish()
	hud._on_song_finish()
	
	_on_exit()
	match game_mode:
		GameMode.STORY:
			if story_stats == null:
				story_stats = GameStats.new()
			if playlist.size() > 1:
				playlist.pop_front()
				Transition.switch_scene(playlist[0].scene)
			else:
				story_stats = null
				Transition.switch_scene(return_scene)
		_:
			#GameMode.FREEPLAY
			story_stats = null
			Transition.switch_scene(return_scene)
