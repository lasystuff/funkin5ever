extends HBoxContainer

var song_id:String = "":
	set(value):
		song_id = value
		var prev_content = ContentManager.current_content
		ContentManager.current_content = content_id
		meta = SongMetadata.get_from_id(song_id)
		%label.text = meta.display_name.to_upper() if meta.display_name.length() > 0 else song_id.to_upper()
		ContentManager.current_content = prev_content
var content_id:String = ""

var meta:SongMetadata
