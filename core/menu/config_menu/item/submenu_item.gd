@tool
extends ConfigItem

@export var submenu_scene:PackedScene

func _process(delta: float) -> void:
	super(delta)
	if !Engine.is_editor_hint():
		if selected:
			if Input.is_action_just_pressed("ui_accept"):
				Transition.switch_scene(submenu_scene)
