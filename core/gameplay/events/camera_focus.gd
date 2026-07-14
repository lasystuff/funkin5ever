extends EventScript

func _call_before_countdown() -> bool:
	return true

func _on_event_call(event:EventData):
	if event.type != "camera_focus":
		return
	
	var target_cam_pos:Vector2 = event.data.get("position", Vector2.ZERO)
	if event.data.has("target"):
		match event.data.target:
			"opponent":
				target_cam_pos += game.opponent.get_camera_pos()
			"spectator":
				target_cam_pos += game.spectator.get_camera_pos()
			_:
				target_cam_pos += game.player.get_camera_pos()
	var duration:float = 2
	if event.data.has("duration"):
		duration = event.data.duration * Conductor.instance.get_step_crotchet(event.time)
	
	var trans:Tween.TransitionType = event.data.get("trans", Tween.TransitionType.TRANS_EXPO)
	var ease:Tween.EaseType = event.data.get("ease", Tween.EaseType.EASE_OUT)
	game.move_camera(target_cam_pos, duration, trans, ease)
