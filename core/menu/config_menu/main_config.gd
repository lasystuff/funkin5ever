extends ConfigSubMenu
class_name MainConfigMenu

static var return_scene:PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if return_scene != null:
		self.back_scene = return_scene
	super()
