extends Node

enum ShaderOption
{
	ALL,
	MINIMAL,
	DISABLED
}

var default_save:Dictionary = { # we don't use const cuz we need to tweak stuff on debug build to release build
	"language": "ja",

	# gameplay
	"keybinds": {},
	"downscroll": false,
	
	# visuals
	"antialiasing": true,
	"shaders": ShaderOption.ALL,
	
	# in-game save TODO: maybe make this binary so they can't edit on text editor or smth
	"_scores": {},
	
	# other (array of {"id": "", "enabled": true})
	"content_list": []
}

var data:Dictionary = {}

func _init() -> void:
	data = default_save.duplicate(true)

	if FileAccess.file_exists("user://save"):
		var saved = str_to_var(FileAccess.get_file_as_string("user://save"))
		# savedata compatibility via version or something idk
		for key in saved.keys():
			data[key] = saved[key]
	
	import_keybind()
	
	TranslationServer.set_locale(data.language)
	
# import keybinds
func import_keybind() -> void:
	for action in data.keybinds:
		var event = InputEventKey.new()
		event.keycode = data.keybinds.get(action)
	
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, event)

func save() -> void:
	data.content_list = ContentManager.create_list_save()
	var f = FileAccess.open("user://save", FileAccess.WRITE)
	f.store_string(var_to_str(data))
	f.close()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save()
