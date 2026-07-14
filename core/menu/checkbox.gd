extends Control

@export var enabled:bool = true
@export var value:bool = true
@export var animation_player:AnimationPlayer
@export var hitbox_area:Area2D
var mouse_overlap:bool = false
		
func _ready() -> void:
	if is_instance_valid(hitbox_area):
		hitbox_area.mouse_entered.connect(func(): mouse_overlap = true)
		hitbox_area.mouse_exited.connect(func(): mouse_overlap = false)

func _input(event) -> void:
	if enabled: return
	if mouse_overlap:
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				toggle()

func toggle(new_value:bool = !value, play_sound:bool = true) -> void:
	if value != new_value:
		value = new_value
		if value:
			animation_player.play("check")
			if play_sound: GlobalSound.play_sfx(load("res://core/menu/confirm.ogg"))
		else:
			animation_player.play("uncheck")
			if play_sound: GlobalSound.play_sfx(load("res://core/menu/cancel.ogg"))
