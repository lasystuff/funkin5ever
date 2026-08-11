extends Control

@export var idle_animation:String = ""
@export var selected_animation:String = ""

@export var selected:bool = false:
	set(value):
		selected = value
		_update_animation()

func _ready() -> void:
	$sprite.animation_finished.connect(_update_animation)
	_update_animation()
	
func _update_animation() -> void:
	if selected:
		$sprite.play(selected_animation)
	else:
		$sprite.play(idle_animation)
