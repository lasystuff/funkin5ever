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
	
	var base_events = BasicChart.get_raw_events(song)
	if base_events.has("events"):
		base.events.append_array(base_events)
		
	for base_event in base.events:
		if base_event.name == "Change BPM":
			chart.bpm_changes.push_back(BPMChange.new(base_event.time / 1000, base_event.args[0]))
	
	return chart
