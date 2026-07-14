extends EventScript

func _on_event_call(event:EventData):
	if event.type != "change_character":
		return
	var target = event.data.get("target", "player")
	
	var character = Character.get_instance(event.data.character)
	
	match target:
		"opponent":
			game.opponent.queue_free()
			game.opponent = character
			game.stage.add_character(character, Stage.CharacterType.OPPONENT)
			if character.facing_left: character.filp_character()
		"spectator":
			game.spectator.queue_free()
			game.spectator = character
			game.stage.add_character(character, Stage.CharacterType.SPECTATOR)
			if character.facing_left: character.filp_character()
		_:
			game.player.queue_free()
			game.player = character
			game.player.add_character(character, Stage.CharacterType.PLAYER)
			if !character.facing_left: character.filp_character()
		
