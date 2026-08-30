@tool
extends Resource
class_name SongMetadata

@export var display_name:String = ""
@export var artist:String = ""
@export var charter:String = ""
@export_category("Extra")
@export var extra_data:Dictionary[String, Variant] = {}

var _song_id:String = ""

static func get_from_id(song:String) -> SongMetadata:
	var tres_path:String = ContentManager.get_content_path("gameplay/songs/" + song + "/meta.tres")
	var result:SongMetadata
	if ResourceLoader.exists(tres_path):
		result = load(tres_path) as SongMetadata
	else:
		result = SongMetadata.new()
	result._song_id = song
	return result

func get_scene() -> PackedScene:
	var scene_path = self.resource_path.replace("meta.tres", "song.tscn")
	if ResourceLoader.exists(scene_path):
		return load(scene_path)
	return null

func get_chart(difficulty:String = "normal") -> Chart:
	var charts_path = self.resource_path.replace("meta.tres", "charts/")
	
	var result:Chart
	
	for format in Chart.CHART_FORMATS:
		var format_instance:BasicChart = format.new()
		if format_instance.check_format(charts_path, difficulty):
			result = format_instance.get_chart(charts_path, difficulty)
	
	if result == null: result = Chart.new()
	
	result.notes.sort_custom(func(a: NoteData, b: NoteData) -> bool:
		if a.time < b.time:
			return true
		return false
	)
	result._song_id = self._song_id
	result._difficulty = difficulty
	
	return result
