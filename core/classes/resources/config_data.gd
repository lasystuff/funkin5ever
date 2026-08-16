extends Resource
class_name ConfigData

const DEFAULT_CONFIG_VERSION:int = 0

enum ShaderOption
{
	ALL,
	MINIMAL,
	DISABLED
}

@export var version:int = DEFAULT_CONFIG_VERSION

# config Variables
@export var middle_scroll:bool = false
@export var keybinds:Keybinds = Keybinds.new()

@export var antialiasing:bool = true
@export var shaders:ShaderOption = ShaderOption.ALL

@export var content_list:Array[Dictionary] = []

func migrate() -> void:
	match self.version:
		_:
			pass
	
	self.version = DEFAULT_CONFIG_VERSION
	
func _on_load() -> void:
	keybinds.load_binds()

func _on_save() -> void:
	content_list = ContentManager.create_list_save()
