@tool
extends ConfigItem

func _ready() -> void:
	if !Engine.is_editor_hint():
		$checkbox.toggle(Config.get_config(save_id), false)

func _process(delta: float) -> void:
	super(delta)
	if !Engine.is_editor_hint():
		if selected:
			if Input.is_action_just_pressed("ui_accept"):
				$checkbox.toggle()
				Config.set_config(save_id, $checkbox.value)
