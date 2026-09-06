extends ConfigSubMenu
class_name MainConfigMenu

static var return_scene:String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !return_scene.is_empty():
		self.back_scene_path = return_scene
	super()
