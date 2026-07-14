extends CanvasLayer

var current_item:int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Gameplay.instance != null:
		%song_name.text = Gameplay.instance.metadata.display_name if !Gameplay.instance.metadata.display_name.is_empty() else Gameplay.instance.chart._song_id
		%difficulty.text = Gameplay.instance.chart._difficulty.to_upper()
		%artist.text = "Artist: " + Gameplay.instance.metadata.artist if !Gameplay.instance.metadata.artist.is_empty() else "Artist: Unknown"
		%charter.text = "Charter: " + Gameplay.instance.metadata.charter if !Gameplay.instance.metadata.charter.is_empty() else "Charter: Unknown"
	change_item(0, false)
	
func change_item(change:int = 0, lerp:bool = true) -> void:
	GlobalSound.play_sfx(preload("res://core/menu/scroll.ogg"))
	current_item = wrap(current_item + change, 0, %items.get_child_count())
	if !lerp:
		%items.global_position.y = 720/2 - $items.get_children()[current_item].position.y
	
func _process(delta: float) -> void:
	%items.global_position.y = lerpf($items.global_position.y, 720/2 - $items.get_children()[current_item].position.y, 0.1)
	if Input.is_action_just_pressed("ui_up"):
		change_item(-1)
	elif Input.is_action_just_pressed("ui_down"):
		change_item(1)
	elif Input.is_action_just_pressed("ui_accept"):
		match $items.get_children()[current_item].name:
			"resume":
				get_tree().paused = false
				self.queue_free()
			"restart":
				get_tree().paused = false
				get_parent().process_mode = Node.PROCESS_MODE_DISABLED
				Gameplay.instance._on_exit()
				Transition.switch_scene(load("res://core/gameplay/gameplay.tscn"))
			"options":
				pass
			"exit":
				get_tree().paused = false
				get_parent().process_mode = Node.PROCESS_MODE_DISABLED
				Gameplay.instance._on_exit()
				Transition.switch_scene(Gameplay.return_scene)
	
	for item in %items.get_children():
		item.modulate.a = 1 if item.get_index() == current_item else 0.5
