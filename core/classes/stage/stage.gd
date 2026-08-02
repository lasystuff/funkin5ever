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
@export var camera_override:StageCamera

func _init() -> void:
	if Conductor.instance != null:
		Conductor.instance.step_hit.connect(_on_step_hit)
		Conductor.instance.beat_hit.connect(_on_beat_hit)
	
	if !is_instance_valid(player_start_point): player_start_point = StageCharacterPosition.new()
	if !is_instance_valid(opponent_start_point): opponent_start_point = StageCharacterPosition.new()
	if !is_instance_valid(spectator_start_point): spectator_start_point = StageCharacterPosition.new()

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
	character.material = point.material

var game:Gameplay:
	get():
		return Gameplay.instance
	
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
