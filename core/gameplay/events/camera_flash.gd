extends EventScript

func _call_before_countdown() -> bool: return true

func _on_event_call(event:EventData):
	if event.type != "camera_flash":
		return
	game.flash_camera(event.data.get("duration", 2), event.data.get("color", Color.WHITE))
