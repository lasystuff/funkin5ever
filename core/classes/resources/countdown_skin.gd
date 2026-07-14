extends Resource
class_name CountdownSkin

@export var scale:float = 0.6
@export_category("Textures")
@export var on_your_mark_texture:Texture2D
@export var ready_texture:Texture2D = preload("res://core/gameplay/countdown/default/ready.png")
@export var set_texture:Texture2D = preload("res://core/gameplay/countdown/default/set.png")
@export var go_texture:Texture2D = preload("res://core/gameplay/countdown/default/go.png")
@export_category("Sound")
@export var on_your_mark_sound:AudioStream = preload("res://core/gameplay/countdown/default/intro3.ogg")
@export var ready_sound:AudioStream = preload("res://core/gameplay/countdown/default/intro2.ogg")
@export var set_sound:AudioStream = preload("res://core/gameplay/countdown/default/intro1.ogg")
@export var go_sound:AudioStream = preload("res://core/gameplay/countdown/default/intro_go.ogg")
