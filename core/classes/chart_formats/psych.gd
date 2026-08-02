extends BasicChart
class_name PsychChart

func check_format(song:String, difficulty:String = "normal") -> bool:
	var base = get_raw_chart(song, difficulty)
	if base.has("format") && base.format.begins_with("psych_v1"):
		return true
	elif base.has("song") && base.song is not String: #legacy
		return true
	return false

func get_chart(song:String, difficulty:String = "normal") -> Chart:
	var legacy:bool = false
	var base = BasicChart.get_raw_chart(song, difficulty)
	if base.song is not String: # legacy format
		legacy = true
		base = base.song
	var chart = Chart.new()
	
	var section_time:float = 0
	var current_bpm:float = base.bpm
	var prev_must_hit:bool = !base.notes[0].mustHitSection
	
	chart.scroll_speed = base.speed
	chart.bpm_changes.push_back(BPMChange.new(0, base.bpm))
	
	chart.player = base.player1
	chart.opponent = base.player2
	chart.spectator = base.get("gfVersion", "gf")
	chart.stage = base.stage
	
	for section in base.notes:
		for base_data in section.sectionNotes:
			var data = NoteData.new()
			data.time = base_data[0] / 1000
			data.column = int(base_data[1]) % 4
			data.length = base_data[2] / 1000
			if base_data.size() > 3:
				if base_data[3] is String:
					data.type = base_data[3]
			
			if legacy:
				if (section.mustHitSection && base_data[1] < 4) or (!section.mustHitSection && base_data[1] > 3):
					data.player = NoteData.PlayerType.PLAYER
				else:
					data.player = NoteData.PlayerType.OPPONENT
			else:
				if base_data[1] < 4:
					data.player = NoteData.PlayerType.PLAYER
				else:
					data.player = NoteData.PlayerType.OPPONENT
			
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
		section_time += ((60 / current_bpm) / 4) * (section.get("lengthInSteps") if section.has("lengthInSteps") else section.get("sectionBeats", 4) * 4)
	
	for base_event in base.events:
		var event_time:float = base_event[0]
		var event_pack:Array = base_event[1]
		for e in event_pack:
			var event = _convert_event(e[0], e[1], e[2])
			event.time = event_time / 1000
			chart.events.push_back(event)
	return chart

func _convert_event(type:String, value1:String, value2:String) -> EventData:
	var event = EventData.new()
	match type:
		"Add Camera Zoom":
			event.type = "camera_bop"
		"Play Animation":
			event.type = "play_animation"
			event.data = {
				"target": _parse_target(value2),
				"animation": value1,
				"force": true
			}
		"Camera Follow Pos":
			event.type = "focus_camera"
			event.data = {
				"position": Vector2(value1.to_float(), value2.to_float())
			}
		"Change Character":
			event.type = "change_character"
			event.data = {
				"target": _parse_target(value1),
				"character": value2
			}
		_: # skip convert
			if !type.is_empty(): # somehow this happens, somehow
				event.type = type
				event.data = {
					"value1": value1,
					"value2": value2
				}
			else:
				event.type = value1
				event.data = {
					"value1": value2,
					"value2": ""
				}
	return event

func _parse_target(target:String) -> String:
	match target.to_lower():
		"gf", "girlfriend", "0", "spectator":
			return "spectator"
		"dad", "1", "opponent":
			return "opponent"
		"bf", "boyfriend", "0", "player":
			return "player"
		_:
			return "player"
