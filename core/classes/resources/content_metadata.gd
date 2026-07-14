extends Resource
class_name ContentMetadata

@export var name:String = ""
@export var global:bool = false
@export_multiline var description:String = ""

@export_category("Gameplay")
@export var freeplay_song_list:Array[String] = []

var id:String = ""
var content_path:String = ""
var enabled:bool = true
