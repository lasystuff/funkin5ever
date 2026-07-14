extends EventScript

func _call_before_countdown() -> bool: return true

func _on_event_call(event:EventData):
	if event.type != "change_camera_bop":
		return
	if event.data.has("interval"):
		game.camera_bop_interval = event.data.interval
	if event.data.has("mult"):
		game.camera_bop_mult = event.data.mult
