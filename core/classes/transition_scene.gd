# yes that it mb
extends Control
class_name TransitionScene

@export var animation_player:AnimationPlayer

func trans_out(callback:Callable) -> void:
	animation_player.play("transition_out")
	await animation_player.animation_finished # we can't use signal for some reason
	callback.call()

func trans_in() -> void:
	animation_player.play("transition_in")
	await animation_player.animation_finished # we can't use signal for some reason
	self.queue_free()
