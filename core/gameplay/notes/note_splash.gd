extends AnimatedSprite2D

var tween:Tween

func play_splash(note_data:NoteData, skin:NoteSkin) -> void:
	self.modulate = Color.WHITE
	self.sprite_frames = skin.splash_frames
	self.play(skin.splash_animations[note_data.column])
	tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.5)
