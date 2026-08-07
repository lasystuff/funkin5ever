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
		var song_name:String = game.metadata.display_name
		if song_name.length() < 1:
			song_name = game.chart._song_id
		song_text.text = "- %s [%s] -" % [song_name, game.chart._difficulty.to_upper()]
	
func _ready_post() -> void:
	_reload_icon()

func _reload_icon() -> void:
	if is_instance_valid(player_icon): player_icon.texture = game.player.health_icon
	if is_instance_valid(opponent_icon): opponent_icon.texture = game.opponent.health_icon

func _on_event_call(event:EventData):
	if event.type != "change_character":
		return
	_reload_icon()

func _update_score():
	if is_instance_valid(score_text):
		score_text.text = "Score: %s • Accuracy: %s [%s] • Combo Breaks: %s" % [game.stats.score, str(floor(game.stats.accuracy)) + "%", game.stats.get_clear_rating(), game.stats.combo_breaks]

func _process(delta:float) -> void:
	_update_score()
	if is_instance_valid(health_bar):
		health_bar.value = game.stats.health
	
	# from psych engine
	var mult:float = lerpf(1, player_icon.scale.x, exp(-delta * 9))
	player_icon.scale = Vector2(game.player.health_icon_scale * mult, game.player.health_icon_scale * mult)
	opponent_icon.scale = Vector2(game.opponent.health_icon_scale * mult, game.opponent.health_icon_scale * mult)
	
	if is_instance_valid(health_bar):
		var bar_pos = health_bar.global_position.x + health_bar.size.x * (1.0 - remap(health_bar.value, 0, 2, 0, 1))
		if is_instance_valid(player_icon): player_icon.global_position.x = bar_pos + 50
		if is_instance_valid(opponent_icon): opponent_icon.global_position.x = bar_pos - 50
	
	if is_instance_valid(player_icon): player_icon.frame = 1 if game.stats.health < 0.4 else 0
	if is_instance_valid(opponent_icon): opponent_icon.frame = 1 if game.stats.health > 1.6 else 0

func _on_beat_hit(beat:int) -> void:
	_bop_icon(beat)

func _bop_icon(beat:int) -> void:
	if beat % 2 == 0:
		if is_instance_valid(player_icon): player_icon.scale = Vector2(1.2, 1.2)
		if is_instance_valid(opponent_icon): opponent_icon.scale = Vector2(1.2, 1.2)

func _on_note_hit(note:Note, strumline:Strumline, judge:String = "sick"):
	if !is_instance_valid(judgement_display):
		return
	if strumline == player_strumline:
		judgement_display.show_judgement(judge, game.stats.combo)

func _on_note_miss(note:Note, strumline:Strumline):
	if !is_instance_valid(judgement_display):
		return
	if strumline == player_strumline:
		judgement_display.hide_judgement()
