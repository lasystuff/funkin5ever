extends CanvasLayer

var default_transition:String ="res://core/menu/transitions/default.tscn"

var skip_out_transition:bool = false
var skip_in_transition:bool = false

func switch_scene(scene:PackedScene, transition_scene:String = default_transition) -> void:
	if transition_scene.is_empty():
		transition_scene = default_transition
		skip_out_transition = true
		skip_out_transition = true
		
	var transition:TransitionScene = load(default_transition).instantiate()
	transition.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(transition)
	if !skip_out_transition:
		transition.trans_out(func():
			get_tree().change_scene_to_packed(scene)
			if !skip_in_transition:
				transition.trans_in()
			else:
				transition.queue_free()
		)
	else:
		get_tree().change_scene_to_packed.call_deferred(scene)
		if !skip_in_transition:
			transition.trans_in()
		else:
			transition.queue_free()
	
	skip_out_transition = false
	skip_in_transition = false
