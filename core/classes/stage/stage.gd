extends Node2D
class_name Stage

enum CharacterType
{
	PLAYER,
	OPPONENT,
	SPECTATOR
}

@export var zoom:float = 1
@export var player_start_point:StageCharacterPosition
@export var opponent_start_point:StageCharacterPosition
@export var spectator_start_point:StageCharacterPosition

@export_category("Camera")
@export var camera_override:Camera2D

@export_category("Gameplay")
@export var hud_scene:PackedScene = preload("res://core/gameplay/hud/default.tscn")
@export var countdown_skin:CountdownSkin = preload("res://core/gameplay/countdown/default/skin.tres")

func _init() -> void:
	if Conductor.instance != null:
		Conductor.instance.step_hit.connect(_on_step_hit)
		Conductor.instance.beat_hit.connect(_on_beat_hit)
	
	if !is_instance_valid(player_start_point): player_start_point = StageCharacterPosition.new()
	if !is_instance_valid(opponent_start_point): opponent_start_point = StageCharacterPosition.new()
	if !is_instance_valid(spectator_start_point): spectator_start_point = StageCharacterPosition.new()
	
func call_event(type:String, data:Dictionary) -> void:
	if game != null:
		var event:EventData = EventData.new()
		event.type = type
		event.data = data if data != null else {}
		event.time = Conductor.instance.song_position
		
		# fuck me two month before
		if !game.event_scripts.has(event.type):
			var script_path = ContentManager.get_content_path("gameplay/events/" + event.type + ".gd")
			if ResourceLoader.exists(script_path):
				var script = load(script_path).new()
				game.event_scripts.set(event.type, script)
				game.scripts.push_back(script)
		
		for script in game.scripts:
			script._on_event_call(event)
		self._on_event_call(event)
		game.hud._on_event_call(event)

func add_character(character:Character, type:CharacterType) -> void:
	add_child(character)
	var point = player_start_point
	match type:
		CharacterType.OPPONENT:
			point = opponent_start_point
		CharacterType.SPECTATOR:
			point = spectator_start_point

	move_child(character, point.get_index())
	character.global_position = point.global_position

var game:Gameplay:
	get():
		return Gameplay.instance if is_instance_valid(Gameplay.instance) else null
	
func _ready() -> void: pass
func _ready_post() -> void: pass

@warning_ignore("unused_parameter")
func _on_countdown_beat(step:int) -> void: pass

@warning_ignore("unused_parameter")
func _process(delta:float) -> void: pass

func _on_song_start() -> void: pass

@warning_ignore("unused_parameter")
func _on_step_hit(step:int) -> void: pass
@warning_ignore("unused_parameter")
func _on_beat_hit(beat:int) -> void: pass

@warning_ignore("unused_parameter")
func _on_event_call(event:EventData): pass

@warning_ignore("unused_parameter")
func _on_note_hit(note:Note, strumline:Strumline, judge:String = "sick"): pass
@warning_ignore("unused_parameter")
func _on_note_miss(note:Note, strumline:Strumline): pass
@warning_ignore("unused_parameter")
func _on_ghost_tap(strumline:Strumline): pass

func _on_song_finish(): pass
