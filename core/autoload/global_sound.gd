extends Node

@onready var sfx_player:AudioStreamPlayer = %sfx_player
@onready var music_player:AudioStreamPlayer = %music_player

func play_sfx(stream:AudioStream) -> void:
	%sfx_player.stop()
	%sfx_player.stream = stream
	%sfx_player.play()

func play_music(stream:AudioStream) -> void:
	%music_player.stop()
	%music_player.stream = stream
	%music_player.play()

func stop_music() -> void:
	%music_player.stop()
