extends Node2D
class_name Character

@export var dance_animations:Array[String] = ["idle"]
@export var animation_player:AnimationPlayer

@export_category("Healthbar")
@export var health_icon:Texture2D = preload("res://core/gameplay/characters/bf/icon.png")
@export var health_icon_scale:float = 1

@export_category("Death Screen")
@export var death_character:PackedScene = preload("res://core/gameplay/characters/bf/dead.tscn")
@export var death_music_postfix:String = ""
@export_custom(PROPERTY_HINT_LINK, "suffix:BPM") var death_music_bpm:float = 100

@export_category("Extra")
@export var extra_data:Dictionary[String, Variant] = {}

var last_sing_beat:int = -1000
var danceable:bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Song.current != null: await Song.current.ready
		
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
	if dance_animations.size() < 1:
		return
	if Conductor.instance.current_beat >= last_sing_beat + 2:
		if beat % dance_thing == 0 && danceable:
			play_anim(dance_animations[dance_index], true)
			dance_index += 1
			if dance_index >= dance_animations.size():
				dance_index = 0

func has_animation(anim:String) -> bool:
	return animation_player.has_animation(anim)

func play_anim(anim:String, force:bool = false):
	if animation_player == null:
		return
	if force:
		animation_player.stop()
	
	animation_player.play(anim)
	if animation_player.current_animation.begins_with("sing_"):
		last_sing_beat = Conductor.instance.current_beat
