extends SongScript
class_name EventScript

func _call_before_countdown() -> bool: return false

@warning_ignore("unused_parameter")
func _on_event_preload(event:EventData) -> void: pass
