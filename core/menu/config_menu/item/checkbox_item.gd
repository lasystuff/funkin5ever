extends ConfigItem

func _ready() -> void:
	$checkbox.toggle(SaveData.data.get(self.save_id), false)

func save_value():
	SaveData.data.set(save_id, $checkbox.value)

func _process(delta: float) -> void:
	if selected:
		if Input.is_action_just_pressed("ui_accept"):
			$checkbox.toggle()
