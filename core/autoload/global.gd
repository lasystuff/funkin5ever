extends Node

var rng:RandomNumberGenerator
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !Engine.is_embedded_in_editor():
		get_window().size *= DisplayServer.screen_get_scale()
		get_window().move_to_center()
	rng = RandomNumberGenerator.new()
