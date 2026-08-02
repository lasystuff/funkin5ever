extends Camera2D
class_name StageCamera

@export var follow_parent:bool = false

var parent_camera:Camera2D

func _process(delta: float) -> void:
	if is_instance_valid(parent_camera):
		if follow_parent:
			self.global_position = parent_camera.global_position
		self.offset = parent_camera.offset

func snap_target_to_self() -> void:
	if is_instance_valid(parent_camera):
		parent_camera.global_position = self.global_position
