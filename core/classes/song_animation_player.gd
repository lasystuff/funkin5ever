extends AnimationPlayer
class_name SongAnimationPlayer

@export var preview_animation:String = "song"
@export var preview_players:Array[AudioStreamPlayer] = []
# weird ass code xd

func _ready() -> void:
	if Gameplay.instance != null:
		for player in preview_players:
			player.volume_db = linear_to_db(0)

var started_song:bool = false

func _process(delta: float) -> void:
	if started_song: return
	
	if Gameplay.instance != null:
		if Gameplay.instance.song_started && Conductor.instance.song_position >= 0:
			started_song = true
	else:
		started_song = true
	
	if started_song:
		if Gameplay.instance != null: self.play(Gameplay.instance.chart._song_id)
		else: self.play(preview_animation)
