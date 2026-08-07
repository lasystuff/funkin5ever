extends EventScript

func _on_event_call(event:EventData):
	if event.type != "play_animation":
		return
	var target = event.data.get("target", "player")
	var force = event.data.get("force", false)
	
	match target:
		"opponent":
			game.opponent.danceable = !force
			game.opponent.play_anim(event.data.animation, force)
		"spectator":
			game.spectator.danceable = !force
			game.spectator.play_anim(event.data.animation, force)
		_:
			game.player.danceable = !force
			game.player.play_anim(event.data.animation, force)
