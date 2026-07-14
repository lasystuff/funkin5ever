@tool
extends Control
class_name Strumline

enum MissType
{
	NOTE_MISS,
	GHOST_TAP,
	HOLD_DROP
}

@export var skin:NoteSkin = preload("res://core/gameplay/notes/default/skin.tres"):
	set(value):
		skin = value
		reload_skin()
@export var botplay:bool = true
@export var play_note_splashes:bool = false

@onready var strums:Array[Node2D] = [%left, %down, %up, %right]

var inputs:Array[String] = ["note_left", "note_down", "note_up", "note_right"]
var note_queues:Array[NoteData] = []
var scroll_speed:float = 1

var note_pool = ScenePool.new(load("res://core/gameplay/notes/note.tscn"))
var splash_pool = ScenePool.new(load("res://core/gameplay/notes/note_splash.tscn"))

signal note_spawned(note: Note)
signal note_hit(note:Note, is_sustain_part:bool)
signal note_miss(note:Note, type:MissType)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reload_skin()
	
	note_hit.connect(_note_hit)
	note_miss.connect(_note_miss)

func reload_skin() -> void:
	%notes.scale = Vector2(skin.scale, skin.scale)
	var idx:int = 0
	for strum in strums:
		strum.sprite_frames = skin.strum_frames
		strum.scale = Vector2(skin.scale, skin.scale)
		strum.play(skin.strum_static_animations[idx])
		idx += 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	for queue in note_queues:
		if queue.time - 3 <= Conductor.instance.song_position:
			var note = note_pool.get_object()
			note.strumline = self
			note.data = queue
			%notes.add_child(note)
			note_queues.erase(queue)
			note_spawned.emit(note)
	
	for note in %notes.get_children():
		note.global_position.x = strums[note.data.column].global_position.x
		note.global_position.y = strums[note.data.column].global_position.y - (Conductor.instance.song_position - note.data.time) * (scroll_speed * 450)
		if botplay && note.data.time <= Conductor.instance.song_position && note.state == Note.NoteState.HITTABLE:
			note_hit.emit(note, false)
		
		if note.state == Note.NoteState.HOLDING:
			if botplay or Input.is_action_pressed(inputs[note.data.column]):
				note_hit.emit(note, true)
			else:
				note_miss.emit(note, MissType.HOLD_DROP)
		
		if note.state == Note.NoteState.MISSED:
			note_miss.emit(note, MissType.NOTE_MISS)
	
	for i in strums.size():
		var strum = strums[i]
		
		if !botplay:
			if Input.is_action_just_pressed(inputs[i]):
				var filtered = %notes.get_children().filter(func(n): return n.state == Note.NoteState.HITTABLE and n.data.column == i)
				if filtered.size() > 0:
					note_hit.emit(filtered[0], false)
				else:
					strum.play(skin.strum_press_animations[i])
			
			if !botplay && !Input.is_action_pressed(inputs[i]):
				strum.play(skin.strum_static_animations[i])
		elif !strum.is_playing():
			strum.play(skin.strum_static_animations[i])

func _note_hit(note:Note, is_sustain_part:bool) -> void:
	strums[note.data.column].play(skin.strum_confirm_animations[note.data.column])
	if note.state == Note.NoteState.HITTABLE:
		if note.data.length > 0:
			note.clip_rect.clip_contents = true
			note.self_modulate = Color.TRANSPARENT
			note.state = Note.NoteState.HOLDING
		else:
			note.state = Note.NoteState.HIT
			note_pool.add_to_pool(note)
		
		if play_note_splashes:
			var splash = splash_pool.get_object()
			%splashes.add_child(splash)
			splash.global_position = strums[note.data.column].global_position
			splash.play_splash(note.data, skin)
			splash.tween.finished.connect(func(): splash_pool.add_to_pool(splash))
	elif note.state == Note.NoteState.HOLDING:
		if note.data.time + note.data.length <= Conductor.instance.song_position:
			note_pool.add_to_pool(note)
		elif !botplay && !Input.is_action_pressed(inputs[note.data.column]):
			note_miss.emit(note)
			return

func _note_miss(note:Note, type:MissType) -> void:
	note_pool.add_to_pool(note)
