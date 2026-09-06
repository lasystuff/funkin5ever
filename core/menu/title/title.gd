extends Node2D

const INTRO_QUOTES:Array[Array] = [
	["shoutouts to tom fulp", "lmao"],
	["Ludum dare", "extraordinaire"],
	["cyberzone", "coming soon"],
	["love to thriftman", "swag"],
	["ultimate rhythm gaming", "probably"],
	["dope ass game", "playstation magazine"],
	["in loving memory of", "henryeyes"],
	["dancin", "forever"],
	["funkin", "forever"],
	["ritz dx", "rest in peace lol"],
	["rate five", "pls no blam"],
	["rhythm gaming", "ultimate"],
	["game of the year", "forever"],
	["you already know", "we really out here"],
	["rise and grind", "love to luis"],
	["like parappa", "but cooler"],
	["album of the year", "chuckie finster"],
	["better than geometry dash", "fight me robtop"],
	["kiddbrute for president", "vote now"],
	["play dead estate", "on newgrounds"],
	["this is a god damn prototype", "we workin on it okay"],
	["women are real", "this is official"],
	["too over exposed", "newgrounds cant handle us"],
	["Hatsune Miku", "biggest inspiration"],
	["too many people", "my head hurts"],
	["newgrounds", "forever"],
	["refined taste in music", "if i say so myself"],
	["his name isnt keith", "dumb eggy lol"],
	["his name isnt evan", "silly tiktok"],
	["stream chuckie finster", "on spotify"],
	["never forget to", "pray to god"],
	["dont play rust", "we only funkin"],
	["good bye", "my penis"],
	["dababy", "biggest inspiration"],
	["fashionably late", "but here it is"],
	["yooooooooooo", "yooooooooo"],
	["pico funny", "pico funny"],
	["updates each friday", "on time every time"],
	["shoutouts to mason", "for da homies"],
	["bonk", "get in the discord call"],
	["carpal tunnel", "game design"],
	["warning", "choking hazard"],
	["devin chat", "what an honorable man"],
	["kickstarter exclusive", "intro text"],
	["cussing", "we have it"],
	["parental advisory", "explicit content"],
	["pico says", "trans rights"],
	["album of the year", "damage control"],
	["proudly made", "via newgrounds pms"],
	["nicotine induced", "game development"],
	["free crackheads", "with love to figburn"],
	["press square", "to open your popit menu"],
	["jojo sez", "shoooooooom"],
	["updates each pico day", "on time every time"],
	["macromedia software", "legally obtained"],
	["under judgement", "proud resident"],
	["make tom proud", "weekly second"],
	["to enable pen pressure", "disable windows ink"]
]

var random_quote:Array

enum TitleState
{
	INTRO,
	MAIN
}

static var intro_seen:bool = false

var state:TitleState = TitleState.INTRO

var conductor:Conductor
var flash_tween:Tween
var controllable:bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !GlobalSound.music_player.playing:
		GlobalSound.play_music(load("res://core/menu/music.ogg"))
	conductor = Conductor.new()
	conductor.beat_hit.connect(_on_beat_hit)
	conductor.set_bpm_changes([BPMChange.new()])
	
	random_quote = INTRO_QUOTES[Global.rng.randi_range(0, INTRO_QUOTES.size() - 1)]
	
	if intro_seen:
		main_sequence()
	else:
		intro_sequence()
		
func intro_sequence() -> void:
	
	$intro.visible = true
	$main.visible = false

func main_sequence() -> void:
	if state == TitleState.MAIN: return
	intro_seen = true
	state = TitleState.MAIN
	
	$intro.visible = false
	$main.visible = true
	
	%press_enter.play("Press Enter to Begin")
	
	%flash.modulate.a = 1
	if flash_tween != null:
		flash_tween.kill()
	flash_tween = get_tree().create_tween()
	flash_tween.tween_property(%flash, "modulate:a", 0, 2)

func _on_beat_hit(beat:int) -> void:
	match beat:
		1:
			%intro_label.text = "THE\nFUNKIN CREW"
		3:
			%intro_label.text += "\nPRESENTS"
		4:
			%intro_label.text = ""
		5:
			%intro_label.text = "IN ASSOCIATION\nWITH"
		7:
			%intro_label.text += "\n[img width=220]core/menu/title/newgrounds_logo.png[/img]"
		8:
			%intro_label.text = ""
		9:
			%intro_label.text = random_quote[0].to_upper()
		11:
			%intro_label.text += "\n" + random_quote[1].to_upper()
		12:
			%intro_label.text = ""
		13:
			%intro_label.text = "FRIDAY"
		14:
			%intro_label.text += "\nNIGHT"
		15:
			%intro_label.text += "\nFUNKIN"
		16:
			main_sequence()
	
	%logo.stop()
	%logo.play("logo bumpin")
	if beat % 2 == 0:
		%gf.stop()
		%gf.play("gfDance")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var music_time:float = (GlobalSound.music_player.get_playback_position() + AudioServer.get_time_since_last_mix())
	conductor.song_position = music_time
	
	if Input.is_action_just_pressed("ui_accept"):
		if state == TitleState.INTRO:
			main_sequence()
		else:
			if controllable:
				controllable = false
				%press_enter.play("ENTER PRESSED")
				GlobalSound.play_sfx(preload("res://core/menu/confirm.ogg"))
				await get_tree().create_timer(1).timeout
				Transition.switch_scene(load("res://core/menu/main_menu/main_menu.tscn"))
