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
	
	return chart
