@tool

extends Camera2D
class_name SongCamera2D

@export var left_marker:Marker2D
@export var right_marker:Marker2D
@export_range(0, 1) var point:float = 0
@export var point_offset:Vector2 = Vector2.ZERO

func _process(delta: float) -> void:
	if is_instance_valid(left_marker) && is_instance_valid(right_marker):
		self.global_position = lerp(left_marker.global_position, right_marker.global_position, point) + point_offset
