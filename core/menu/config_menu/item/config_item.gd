@tool
extends HBoxContainer
class_name ConfigItem

@export var display_name:String
@export var label:Label
@export var save_id:String = ""

var selected:bool = false

func save_value():
	pass

func _process(delta: float) -> void:
	if is_instance_valid(label) && !display_name.is_empty() && label.text != display_name:
		label.text = display_name
