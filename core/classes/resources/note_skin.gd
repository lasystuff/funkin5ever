extends Resource
class_name NoteSkin

@export_category("Metadata")
@export var scale:float = 0.7
@export var sing_animations:Array[String] = ["sing_left", "sing_down", "sing_up", "sing_right"]

@export_category("Strum")
@export var strum_frames:SpriteFrames = preload("res://core/gameplay/notes/default/notes.xml")

@export var strum_static_animations:Array[String] = ["arrowLEFT", "arrowDOWN", "arrowUP", "arrowRIGHT"]
@export var strum_press_animations:Array[String] = ["left press", "down press", "up press", "right press"]
@export var strum_confirm_animations:Array[String] = ["left confirm", "down confirm", "up confirm", "right confirm"]

@export_category("Note")
@export var note_frames:SpriteFrames = preload("res://core/gameplay/notes/default/notes.xml")
@export var note_animations:Array[String] = ["purple", "blue", "green", "red"]


@export_category("Sustain Note")
@export var sustain_frame_left:Texture2D = preload("res://core/gameplay/notes/default/sustains/left.png")
@export var sustain_frame_left_end:Texture2D = preload("res://core/gameplay/notes/default/sustains/left_end.png")
@export var sustain_frame_down:Texture2D = preload("res://core/gameplay/notes/default/sustains/down.png")
@export var sustain_frame_down_end:Texture2D = preload("res://core/gameplay/notes/default/sustains/down_end.png")
@export var sustain_frame_up:Texture2D = preload("res://core/gameplay/notes/default/sustains/up.png")
@export var sustain_frame_up_end:Texture2D = preload("res://core/gameplay/notes/default/sustains/up_end.png")
@export var sustain_frame_right:Texture2D = preload("res://core/gameplay/notes/default/sustains/right.png")
@export var sustain_frame_right_end:Texture2D = preload("res://core/gameplay/notes/default/sustains/right_end.png")

@export_category("Splashes")
@export var splash_frames:SpriteFrames = preload("res://core/gameplay/notes/default/splashes.xml")
@export var splash_animations:Array[String] = ["note splash purple 1", "note splash blue 1", "note splash green 1", "note splash red 1"]
