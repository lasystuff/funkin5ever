extends Node

# THIS IS JUST A DEFAULT SETTING FOR DISCORD RPC

func _init() -> void:
	DiscordRPC.app_id = 1545463394851749979
	menu()

func song() -> void:
	if Song.current != null:
		DiscordRPC.details = (Song.current.meta.display_name if !Song.current.meta.display_name.is_empty() else Song.current.meta._song_id) + " [%s]" % Song.current.chart._difficulty.to_upper()
		DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system())
		DiscordRPC.refresh()

func menu() -> void:
	DiscordRPC.details = "In the Menus"
	DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system())
	DiscordRPC.refresh()
