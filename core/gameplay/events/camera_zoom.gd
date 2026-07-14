extends EventScript

func _call_before_countdown() -> bool: return true

func _on_event_call(event:EventData):
	if event.type != "camera_zoom":
		return

	var duration = event.data.get("speed", 1) * Conductor.instance.get_crotchet(event.time)
	var trans:Tween.TransitionType = event.data.get("trans", Tween.TransitionType.TRANS_CUBIC)
	var ease:Tween.EaseType = event.data.get("ease", Tween.EaseType.EASE_OUT)

	game.zoom_camera(event.data.value, duration, trans, ease)
