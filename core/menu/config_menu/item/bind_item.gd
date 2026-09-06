@tool
extends ConfigItem

var binding:bool = false
var timer:float = 0

func _process(delta: float) -> void:
	if !Engine.is_editor_hint():
		var thing:String = OS.get_keycode_string(Config.data.keybinds.get(save_id)).to_upper() if !binding else "PRESS KEY"
		if is_instance_valid(label) && !display_name.is_empty() && label.text != display_name:
			label.text = display_name + ": " + thing
		
		if selected:
			if Input.is_action_just_pressed("ui_accept") && timer > 0.1:
				if !binding:
					binding = true
					(get_parent().get_parent() as ConfigSubMenu).controllable = false
	else:
		super(delta)
	timer += delta
	
func _input(event: InputEvent) -> void:
	if !binding: return
	
	if event is InputEventKey && (event as InputEventKey).is_pressed() && !(event as InputEventKey).echo:
		timer = 0
		Config.data.keybinds.set(self.save_id, (event as InputEventKey).keycode)
		binding = false
		(get_parent().get_parent() as ConfigSubMenu).controllable = true
		Config.data.keybinds.reload_binds()
