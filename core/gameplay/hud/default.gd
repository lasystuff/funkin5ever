extends HUD

@export var watermark:Label
@export var health_bar:TextureProgressBar
@export var opponent_icon:Sprite2D
@export var player_icon:Sprite2D
@export var song_text:Label
@export var score_text:Label
@export var judgement_display:JudgementDisplay

func _ready() -> void:
	if is_instance_valid(song_text):
		var song_name:String = Song.current.meta.display_name
		if song_name.length() < 1:
			song_name = Song.current.chart._song_id
		song_text.text = "- %s [%s] -" % [song_name, Song.current.chart._difficulty.to_upper()]
	apply_config()

func apply_config() -> void:
	if Config.get_config("down_scroll"):
		if is_instance_valid(health_bar): health_bar.position.y -= 580
		if is_instance_valid(player_strumline):
			player_strumline.down_scroll = true
			player_strumline.position.y += 530
		if is_instance_valid(opponent_strumline):
			opponent_strumline.down_scroll = true
			opponent_strumline.position.y += 530
		if is_instance_valid(judgement_display):
			judgement_display.position.y += 510
	if Config.get_config("middle_scroll"):
		if is_instance_valid(player_strumline):
			player_strumline.position.x = 416
		if is_instance_valid(opponent_strumline):
			opponent_strumline.visible = false
		if is_instance_valid(judgement_display):
			judgement_display.position.x -= 350

func _ready_post() -> void:
	_reload_icon()

func _reload_icon() -> void:
	if is_instance_valid(player_icon) && player_strumline.characters.size() > 0: player_icon.texture = player_strumline.characters[0].health_icon
	if is_instance_valid(opponent_icon) && opponent_strumline.characters.size() > 0: opponent_icon.texture = opponent_strumline.characters[0].health_icon

func _update_score():
	if is_instance_valid(score_text):
		score_text.text = "Score: %s • Accuracy: %s [%s] • Combo Breaks: %s" % [Song.current.stats.score, str(floor(Song.current.stats.accuracy)) + "%", Song.current.stats.get_clear_rating(), Song.current.stats.combo_breaks]

func _process(_delta:float) -> void:
	_update_score()
	if is_instance_valid(health_bar):
		health_bar.value = Song.current.stats.health
	
	_update_icon_positions()
	_update_icon_states()

func _update_icon_positions() -> void:
	if is_instance_valid(health_bar):
		var bar_pos: float = health_bar.global_position.x + health_bar.size.x * (1.0 - remap(health_bar.value, 0, 2, 0, 1))
		if is_instance_valid(player_icon): player_icon.global_position.x = bar_pos + 50
		if is_instance_valid(opponent_icon): opponent_icon.global_position.x = bar_pos - 50

func _update_icon_states() -> void:
	if is_instance_valid(player_icon):
		player_icon.frame = 1 if Song.current.stats.health < 0.4 else 0
	if is_instance_valid(opponent_icon):
		opponent_icon.frame = 1 if Song.current.stats.health > 1.6 else 0


func _on_beat_hit(beat:int) -> void:
	_bop_icon(beat)

var icon_tween:Tween

func _bop_icon(beat:int) -> void:
	if beat % 2 == 0:
		if !is_instance_valid(player_icon) && !is_instance_valid(opponent_icon): return
		if is_instance_valid(icon_tween): icon_tween.kill()
		
		var player_scale: float = player_strumline.characters[0].health_icon_scale if player_strumline.characters.size() > 0 else 1.0
		var opponent_scale: float = opponent_strumline.characters[0].health_icon_scale if opponent_strumline.characters.size() > 0 else 1.0
		
		icon_tween = get_tree().create_tween().set_parallel(true).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
		
		if is_instance_valid(player_icon):
			player_icon.scale = Vector2(player_scale * 1.14, player_scale * 1.14)
			icon_tween.tween_property(player_icon, "scale", Vector2(player_scale, player_scale), Conductor.instance.get_crotchet())
		if is_instance_valid(opponent_icon):
			opponent_icon.scale = Vector2(opponent_scale * 1.14, opponent_scale * 1.14)
			icon_tween.tween_property(opponent_icon, "scale", Vector2(player_scale, player_scale), Conductor.instance.get_crotchet())

func _on_note_hit(_note:Note, strumline:Strumline, judge:String = "sick"):
	if !is_instance_valid(judgement_display):
		return
	if strumline == player_strumline:
		judgement_display.show_judgement(judge, Song.current.stats.combo)

func _on_note_miss(_note:Note, strumline:Strumline):
	if !is_instance_valid(judgement_display):
		return
	if strumline == player_strumline:
		judgement_display.hide_judgement()
