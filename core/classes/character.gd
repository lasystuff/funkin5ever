extends Node2D
class_name Character

@export var facing_left:bool = false
@export var dance_animations:Array[String] = ["idle"]
@export var camera_offset:Node2D
@export var animation_player:AnimationPlayer

@export_category("Healthbar Properties")
@export var health_icon:Texture2D = load("res://core/gameplay/characters/bf/icon.png")
@export var health_icon_scale:float = 1

var last_sing_beat:int = -1000
var danceable:bool = true
var flipped:bool = false

static func get_instance(id:String) -> Character:
	var character_path:String = ContentManager.get_content_path("gameplay/characters/" + id)
	if !DirAccess.dir_exists_absolute(character_path): character_path = ContentManager.get_content_path("gameplay/characters/bf")
	return load(character_path.path_join("character.tscn")).instantiate()
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if camera_offset == null:
		camera_offset = Node2D.new()
		
	if Conductor.instance != null:
		Conductor.instance.beat_hit.connect(beat_hit)

	if dance_animations.size() > 1:
		dance_thing = 1
	animation_player.animation_finished.connect(func(_anim):
		danceable = true
	)
	
	beat_hit(0)

var dance_index:int = 0
var dance_thing = 2
func beat_hit(beat:int) -> void:
	if Conductor.instance.current_beat >= last_sing_beat + 2:
		if beat % dance_thing == 0 && danceable:
			play_anim(dance_animations[dance_index], true)
			dance_index += 1
			if dance_index >= dance_animations.size():
				dance_index = 0
				
func get_camera_pos() -> Vector2:
	return camera_offset.global_position

func has_animation(anim:String) -> bool:
	return animation_player.has_animation(anim)

func play_anim(anim:String, force:bool = false):
	if animation_player == null:
		return
	if force:
		animation_player.stop()
	
	if flipped && anim == "sing_left":
		anim = "sing_right"
	elif flipped && anim == "sing_right":
		anim = "sing_left"
	
	animation_player.play(anim)
	if animation_player.current_animation.begins_with("sing_"):
		last_sing_beat = Conductor.instance.current_beat

func flip_character() -> void:
	#camera_offset.position.x *= -1
	flipped = !flipped
	self.scale.x *= -1
