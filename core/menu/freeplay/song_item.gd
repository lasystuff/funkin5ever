extends HBoxContainer

var song_id:String = "":
	set(value):
		song_id = value
		var prev_content = ContentManager.current_content
		ContentManager.current_content = content_id
		var meta = SongMetadata.get_from_id(song_id)
		%label.text = meta.display_name.to_upper() if meta.display_name.length() > 0 else song_id.to_upper()
		ContentManager.current_content = prev_content
var content_id:String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
