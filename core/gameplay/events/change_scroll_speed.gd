extends EventScript

func _call_before_countdown() -> bool: return true

func _on_event_call(event:EventData):
	if event.type != "change_scroll_speed":
		return
	
	if event.data.get("duration", 0) != 0:
		var tween:Tween = game.get_tree().create_tween()
		
		var trans:Tween.TransitionType = event.data.get("trans", Tween.TransitionType.TRANS_EXPO)
		var ease:Tween.EaseType = event.data.get("ease", Tween.EaseType.EASE_OUT)
		tween.set_trans(trans).set_ease(ease).set_parallel()
		
		tween.tween_property(game.hud.player_strumline, "scroll_speed", game.chart.scroll_speed * event.data.value, Conductor.instance.get_step_crotchet() * event.data.get("duration"))
		tween.tween_property(game.hud.opponent_strumline, "scroll_speed", game.chart.scroll_speed * event.data.value, Conductor.instance.get_step_crotchet() * event.data.get("duration"))
	else:
		game.hud.player_strumline.scroll_speed = game.chart.scroll_speed * event.data.value
		game.hud.opponent_strumline.scroll_speed = game.chart.scroll_speed * event.data.value
