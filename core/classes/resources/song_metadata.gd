extends Resource
class_name SongMetadata

@export var scene:PackedScene
@export_category("Info")
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
