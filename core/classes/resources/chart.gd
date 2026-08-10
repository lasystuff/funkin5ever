extends Resource
class_name Chart

var _song_id:String = ""
var _difficulty:String = ""

@export var notes:Array[NoteData] = []

@export var scroll_speed:float = 1
@export var bpm_changes:Array[BPMChange] = []

static var CHART_FORMATS = [VSliceChart, CodenameChart, NightmareVisionChart, PsychChart]

static func get_from_id(song:String, difficulty:String = "normal") -> Chart:
	for format in CHART_FORMATS:
		var format_instance:BasicChart = format.new()
		if format_instance.check_format(song, difficulty):
			var result:Chart = format_instance.get_chart(song, difficulty)
			result._song_id = song
			result._difficulty = difficulty
			result.notes.sort_custom(sort_by_time)
			return result
	return Chart.new()

static func sort_by_time(a: NoteData, b: NoteData) -> bool:
	if a.time < b.time:
		return true
	return false
