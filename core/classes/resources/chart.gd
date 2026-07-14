extends Resource
class_name Chart

var _song_id:String = ""
var _difficulty:String = ""

@export var notes:Array[NoteData] = []
@export var events:Array[EventData] = []

@export var scroll_speed:float = 1
@export var bpm_changes:Array[BPMChange] = []

@export var stage:String = "stage"
@export var player:String = "bf"
@export var opponent:String = "bf"
@export var spectator:String = "bf"

static var CHART_FORMATS = [VSliceChart, CodenameChart, NightmareVisionChart, PsychChart]

static func get_from_id(song:String, difficulty:String = "normal") -> Chart:
	for format in CHART_FORMATS:
		var format_instance = format.new()
		if format_instance.check_format(song, difficulty):
			var result = format_instance.get_chart(song, difficulty)
			result._song_id = song
			result._difficulty = difficulty
			result.notes.sort_custom(sort_by_time)
			result.events.sort_custom(sort_by_time)
			return result
	return Chart.new()

static func sort_by_time(a, b) -> bool:
	if a.time < b.time:
		return true
	return false
