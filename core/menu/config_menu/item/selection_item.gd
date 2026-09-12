@tool
extends ConfigItem

@export var values:Array[String] = []

var value:String = ""

func _ready() -> void:
	if !Engine.is_editor_hint():
		value = Config.get_config(save_id, value)

func _process(delta: float) -> void:
	super(delta)
	if !Engine.is_editor_hint():
		if selected:
			if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
				GlobalSound.play_sfx(load("res://core/menu/scroll.ogg"))
				var change:int = 1 if Input.is_action_just_pressed("ui_right") else -1
				value = values[wrap(values.find(value) + change, 0, values.size())]
				Config.set_config(save_id, value)
		$label.text = display_name + ": " + value
