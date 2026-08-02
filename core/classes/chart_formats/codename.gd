extends BasicChart
class_name CodenameChart

func check_format(song:String, difficulty:String = "normal") -> bool:
	var base = get_raw_chart(song, difficulty)
	if base.has("codenameChart"):
		return true
	elif base.has("strumLines"):
		return true
	return false

func get_chart(song:String, difficulty:String = "normal") -> Chart:
	var base = BasicChart.get_raw_chart(song, difficulty)
	var meta = BasicChart.get_raw_meta(song)
	var chart = Chart.new()
	
	chart.bpm_changes.push_back(BPMChange.new(0, meta.bpm))
	
	chart.stage = base.stage
	chart.scroll_speed = base.scrollSpeed
	
	base.noteTypes.push_front("")
	
	for strumline in base.strumLines:
		for base_note in strumline.notes:
			var note_data:NoteData = NoteData.new()
			note_data.time = base_note.time / 1000
			note_data.column = base_note.id
			note_data.length = base_note.sLen / 1000
			note_data.type = base.noteTypes[int(base_note.type)]
			if base.strumLines.find(strumline) == 0: # opponent
				note_data.player = NoteData.PlayerType.OPPONENT
			else: # player
				note_data.player = NoteData.PlayerType.PLAYER
			chart.notes.push_back(note_data)
		
		if base.strumLines.find(strumline) == 0: # opponent
			chart.opponent = strumline.characters[0]
		elif base.strumLines.find(strumline) == 2:
			chart.spectator = strumline.characters[0]
		else:
			chart.player = strumline.characters[0]
	
	var base_events = BasicChart.get_raw_events(song)
	if base_events.has("events"):
		base.events.append_array(base_events)
		
	for base_event in base.events:
		if base_event.name == "Change BPM":
			chart.bpm_changes.push_back(BPMChange.new(base_event.time / 1000, base_event.args[0]))
		else:
			var event_data = EventData.new()
			event_data.time = base_event.time / 1000
			match base_event.name:
				"Camera Movement":
					event_data.type = "camera_focus"
					event_data.data.target = ["opponent", "player", "spectator"][base_event.params[0]]
					if _get_arg(base_event.params, 1, true):
						if _get_arg(base_event.params, 3, "CLASSIC") != "CLASSIC":
							event_data.data.duration = _get_arg(base_event.params, 2, 4)
							event_data.data.trans = parse_ease(_get_arg(base_event.params, 3, "expo"))
							event_data.data.ease = parse_ease(_get_arg(base_event.params, 4, "Out"))
					else:
						event_data.data.duration = 0
				"HScript Call":
					event_data.type = base_event.params[0]
					if base_event.size() > 0:
						event_data.data = {
							"args": _get_arg(base_event.params, 1, "").split(",")
						}
				"Camera Modulo Change":
					event_data.type = "change_camera_bop"
					event_data.data = {
						"interval": _get_arg(base_event.params, 0, 4),
						"mult": _get_arg(base_event.params, 1, 1)
					}
				"Camera Flash":
					event_data.type = "camera_flash"
					event_data.data = {
						#"color": Color.hex(_get_arg(base_event.params, 1, -1)), # i dont fucking care
						"duration": _get_arg(base_event.params, 2, 10) / 4
					}
				"Camera Zoom":
					event_data.type = "camera_zoom"
					event_data.data.value = _get_arg(base_event.params, 1, 1)
					if _get_arg(base_event.params, 0, true):
						if _get_arg(base_event.params, 3, null) != null:
							event_data.data.duration = _get_arg(base_event.params, 3, null)
						event_data.data.trans = parse_trans(_get_arg(base_event.params, 4, "linear"))
						event_data.data.ease = parse_ease(_get_arg(base_event.params, 5, "Out"))
					else:
						event_data.data.duration = 0
				"Add Camera Zoom":
					event_data.type = "camera_bop"
				_:
					event_data.type = base_event.name
					event_data.data = {
						"params": base_event.params
					}
			chart.events.push_back(event_data)
	
	return chart
	
func get_metadata(song:String) -> SongMetadata:
	var base = BasicChart.get_raw_meta(song)
	var meta = SongMetadata.new()
	meta.display_name = base.displayName
	return meta
	
func _get_arg(args:Array[Variant], index:int, default:Variant) -> Variant:
	if args.size() < index + 1:
		return default
	else:
		return args[index]

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
