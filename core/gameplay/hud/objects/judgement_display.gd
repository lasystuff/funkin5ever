extends Control
class_name JudgementDisplay

@export var judgement_textures:Dictionary[String, Texture2D] = {
	"sick": preload("res://core/gameplay/hud/judgements/sick.png"),
	"good": preload("res://core/gameplay/hud/judgements/good.png"),
	"bad": preload("res://core/gameplay/hud/judgements/bad.png"),
	"shit": preload("res://core/gameplay/hud/judgements/shit.png")
}

@export var judgement:Sprite2D
@export var combo:Label

var _initial_judge_scale:Vector2 = Vector2.ONE

var judge_tween:Tween

func _ready() -> void:
	judgement.visible = false
	combo.visible = false
	
	_initial_judge_scale = Vector2(judgement.scale)

func show_judgement(judge:String = "sick", combo_count:int = 0) -> void:
	judgement.visible = true
	combo.visible = true
	
	judgement.texture = judgement_textures.get(judge)
	
	if combo_count > 1:
		combo.text = str(combo_count)
	
	if judge_tween != null:
		judge_tween.kill()
	
	judgement.scale = _initial_judge_scale * 1.1
	judge_tween = get_tree().create_tween().set_parallel().set_trans(Tween.TransitionType.TRANS_EXPO).set_ease(Tween.EaseType.EASE_OUT)
	judge_tween.tween_property(judgement, "scale", _initial_judge_scale, Conductor.instance.get_crotchet() * 0.9)

func hide_judgement() -> void:
	judgement.visible = false
	combo.visible = false
