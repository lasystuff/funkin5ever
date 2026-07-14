extends BasicChart
class_name NightmareVisionChart

func check_format(song:String, difficulty:String = "normal") -> bool:
	var base = get_raw_chart(song, difficulty)
	if base.has("song") && base.song is not String:
		if base.song.has("format") && base.song.format.begins_with("nmv"):
			return true
	return false

func get_chart(song:String, difficulty:String = "normal") -> Chart:
	var base = BasicChart.get_raw_chart(song, difficulty).song
	var chart = Chart.new()
	
	var section_time:float = 0
	var current_bpm:float = base.bpm
	var prev_must_hit:bool = !base.notes[0].mustHitSection
	
	chart.scroll_speed = base.speed
	chart.bpm_changes.push_back(BPMChange.new(0, base.bpm))
	
	chart.player = base.player1
	chart.opponent = base.player2
	chart.spectator = base.gfVersion
	chart.stage = base.stage
	
	for section in base.notes:
		for base_data in section.sectionNotes:
			var data = NoteData.new()
			data.time = base_data[0] / 1000
			data.column = int(base_data[1]) % 4
			data.length = base_data[2] / 1000
			data.type = base_data[3] if base_data.size() > 3 else ""
			if base_data[1] > 3:
				data.player = NoteData.PlayerType.OPPONENT
			else:
				data.player = NoteData.PlayerType.PLAYER
			
			chart.notes.push_back(data)
		
		if section.mustHitSection != prev_must_hit:
			var camera_event = EventData.new()
			camera_event.time = section_time
			camera_event.type = "camera_focus"
			camera_event.data = {
				"target": "player" if section.mustHitSection else "opponent"
			}
			
			chart.events.push_back(camera_event)
			prev_must_hit = section.mustHitSection
		
		if section.get("changeBPM", false):
			chart.bpm_changes.push_back(BPMChange.new(section_time, section.bpm))
			current_bpm = section.bpm
		section_time += ((60 / current_bpm) / 4) * section.get("lengthInSteps", 16)
	
	return chart

func get_metadata(song:String) -> SongMetadata:
	var base = BasicChart.get_raw_meta(song)
	var meta = SongMetadata.new()
	
	if base.has("songName"):
		meta.display_name = base.songName
	if base.has("composers"):
		meta.artist = ", ".join(base.composers)
	if base.has("charters"):
		meta.charter = ", ".join(base.charters)
	
	return meta
