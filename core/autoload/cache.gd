extends Node

func _init() -> void:
	await ContentManager.ready
	reload()

func reload() -> void:
	pass
