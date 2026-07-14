extends RefCounted
class_name BasicChart

@warning_ignore("unused_parameter")
func check_format(song:String, difficulty:String = "normal") -> bool: return false

@warning_ignore("unused_parameter")
func get_chart(song:String, difficulty:String = "normal") -> Chart: return Chart.new()
@warning_ignore("unused_parameter")
func get_metadata(song:String) -> SongMetadata: return SongMetadata.new()

static func get_raw_chart(song:String, difficulty:String = "normal") -> Dictionary:
	var folder = ContentManager.get_content_path("gameplay/songs/" + song)
	if ResourceLoader.exists(folder.path_join(difficulty + ".json")): # hard.json
		return load(folder.path_join(difficulty + ".json")).data
	if ResourceLoader.exists(folder.path_join(song + "-" + difficulty + ".json")): # song_name-hard.json
		return load(folder.path_join(song + "-" + difficulty + ".json")).data
	if ResourceLoader.exists(folder.path_join(song + ".json")): # song_name.json
		return load(folder.path_join(song + "-" + difficulty + ".json")).data
	if ResourceLoader.exists(folder.path_join("chart-" + difficulty + ".json")): # chart-hard.json
		return load(folder.path_join("chart-" + difficulty + ".json")).data
	if ResourceLoader.exists(folder.path_join("chart.json")): # chart.json
		return load(folder.path_join("chart.json")).data
	if ResourceLoader.exists(folder.path_join(song + "-chart.json")): # song_name-chart.json
		return load(folder.path_join(song + "-chart.json")).data
	return {}

static func get_raw_meta(song:String) -> Dictionary:
	var folder = ContentManager.get_content_path("gameplay/songs/" + song)
	if ResourceLoader.exists(folder.path_join("meta.json")): # meta.json
		return load(folder.path_join("meta.json")).data
	elif ResourceLoader.exists(folder.path_join("metadata.json")): # metadata.json
		return load(folder.path_join("metadata.json")).data
	elif ResourceLoader.exists(folder.path_join(song + "-metadata.json")): # song_name-metadata.json
		return load(folder.path_join(song + "-metadata.json")).data
	return {}

# IS THAT IT????? REALLY????
static func get_raw_events(song:String) -> Dictionary:
	var folder = ContentManager.get_content_path("gameplay/songs/" + song)
	if ResourceLoader.exists(folder.path_join("events.json")): # events.json
		return load(folder.path_join("events.json")).data
	return {}
