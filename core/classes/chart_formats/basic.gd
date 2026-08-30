extends RefCounted
class_name BasicChart

@warning_ignore("unused_parameter")
func check_format(chart_path:String, difficulty:String = "normal") -> bool: return false

@warning_ignore("unused_parameter")
func get_chart(chart_path:String, difficulty:String = "normal") -> Chart: return Chart.new()

static func get_raw_chart(folder:String, difficulty:String = "normal") -> Dictionary:
	if ResourceLoader.exists(folder.path_join(difficulty + ".json")): # hard.json
		return load(folder.path_join(difficulty + ".json")).data
	if ResourceLoader.exists(folder.path_join("chart.json")): # chart.json
		return load(folder.path_join("chart.json")).data
	return {}

static func get_raw_meta(folder:String) -> Dictionary:
	if ResourceLoader.exists(folder.path_join("meta.json")): # meta.json
		return load(folder.path_join("meta.json")).data
	elif ResourceLoader.exists(folder.path_join("metadata.json")): # metadata.json
		return load(folder.path_join("metadata.json")).data
	return {}

# IS THAT IT????? REALLY????
static func get_raw_events(folder:String) -> Dictionary:
	if ResourceLoader.exists(folder.path_join("events.json")): # events.json
		return load(folder.path_join("events.json")).data
	return {}
