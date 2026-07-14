extends BasicChart
class_name VSliceChart

func check_format(song:String, difficulty:String = "normal") -> bool:
	var base = get_raw_chart(song, difficulty)
	if base.has("hard") or base.has("easy") or base.has("normal") or base.has("erect"):
		return true
	elif base.has("generatedBy") and base.generatedBy.contains("Friday Night Funkin'"):
		return true
	return false

func get_chart(song:String, difficulty:String = "normal") -> Chart:
	var base = BasicChart.get_raw_chart(song, difficulty)
	var meta = BasicChart.get_raw_meta(song)
	var chart = Chart.new()
	
	for original_change in meta.timeChanges:
		chart.bpm_changes.push_back(BPMChange.new(original_change.t / 1000, original_change.bpm, original_change.n, original_change.d))
	
	chart.player = meta.playData.characters.player
	chart.spectator = meta.playData.characters.girlfriend
	chart.opponent = meta.playData.characters.opponent
	chart.stage = meta.playData.stage
	chart.scroll_speed = base.scrollSpeed.get(difficulty)
	
	for base_note in base.notes.get(difficulty):
		var note_data:NoteData = NoteData.new()
		note_data.time = base_note.t / 1000
		note_data.column = int(base_note.d) % 4
		note_data.length = base_note.l / 1000
		note_data.type = base_note.get("k", "")
		if base_note.d > 3: # opponent
			note_data.player = NoteData.PlayerType.OPPONENT
		else: # player
			note_data.player = NoteData.PlayerType.PLAYER
		chart.notes.push_back(note_data)
		
	for base_event in base.events:
		var event_data = EventData.new()
		event_data.time = base_event.t / 1000
		match base_event.e:
			"FocusCamera":
				event_data.type = "camera_focus"
				event_data.data.target = ["player", "opponent", "spectator"][base_event.v.char]
				if base_event.v.get("ease", "CLASSIC") != "CLASSIC":
					event_data.data.duration = base_event.v.duration
					event_data.data.trans = parse_trans(_split_ease(base_event.v.get("ease"))[0])
					if base_event.v.has("easeDir"):
						event_data.data.ease = parse_ease(base_event.v.easeDir)
					else:
						event_data.data.ease = parse_ease(_split_ease(base_event.v.get("ease"))[1])
				if base_event.v.has("x") or base_event.v.has("y"):
					event_data.data.position = Vector2(base_event.v.get("x", 0), base_event.v.get("y", 0))
			"ZoomCamera":
				event_data.type = "camera_zoom"
				event_data.data.value = base_event.v.zoom
					
				event_data.data.duration = base_event.v.duration
				event_data.data.trans = parse_trans(_split_ease(base_event.v.get("ease"))[0])
				if base_event.v.has("easeDir"):
					event_data.data.ease = parse_ease(base_event.v.easeDir)
				else:
					event_data.data.ease = parse_ease(_split_ease(base_event.v.get("ease"))[1])
		chart.events.push_back(event_data)
	
	return chart
	
func get_metadata(song:String) -> SongMetadata:
	var base = BasicChart.get_raw_meta(song)
	var meta = SongMetadata.new()
	meta.display_name = base.songName
	meta.artist = base.artist
	meta.charter = base.charter
	return meta

func parse_ease(input:String) -> int:
	
	var flixel_eases = ["In", "Out", "InOut", "OutIn"]
	
	var result = flixel_eases.find(input)
	if result < 0:
		result = 0
	return result
	
func parse_trans(input:String) -> int:
	var flixel_transes = ["linear", "sine", "quint", "quart", "quad", "expo", "elastic", "cubic", "circ", "bounce", "back"]
	
	if input.ends_with("smoother"):
		input = input.split("smoother")[0].to_lower()
	if input.ends_with("smooth"):
		input = input.split("smooth")[0].to_lower()
	if input == "step":
		return Tween.TRANS_CUBIC
	var result = flixel_transes.find(input)
	if result < 0:
		result = 0
	return result

func _split_ease(input:String) -> Array[String]:
	if input.ends_with("InOut"):
		return [input.split("InOut")[0], "InOut"]
	if input.ends_with("Out"):
		return [input.split("Out")[0], "Out"]
	if input.ends_with("In"):
		return [input.split("In")[0], "In"]
	return [input, ""]
