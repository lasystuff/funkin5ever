extends Resource
class_name ContentMetadata

@export var name:String = ""
@export_multiline var description:String = ""
@export var initial_scene:PackedScene

@export_category("Gameplay")
@export var freeplay_song_list:Array[SongMetadata] = []

var id:String = ""
var content_path:String = ""
var enabled:bool = true
