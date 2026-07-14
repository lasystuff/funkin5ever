extends EventScript

func _call_before_countdown() -> bool: return true

func _on_event_call(event:EventData):
	if event.type != "camera_bop":
		return
	game.camera_bop_add = 0.1
