extends Resource
class_name SongMetadata

@export var display_name:String = ""
@export var artist:String = ""
@export var charter:String = ""

static func get_from_id(song:String) -> SongMetadata:
	var tres_path:String = ContentManager.get_content_path("gameplay/songs/" + song + "/meta.tres")
	if ResourceLoader.exists(tres_path):
		return load(tres_path) as SongMetadata
	
	for format in Chart.CHART_FORMATS:
		var format_instance:BasicChart = format.new()
		if format_instance.check_format(song):
			return format_instance.get_metadata(song)
	return SongMetadata.new()
