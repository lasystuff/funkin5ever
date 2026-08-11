extends RefCounted
class_name GameStats

# constants
const SICK_SCORE:int = 350
const SICK_HEALTH_ADD:float = 0.02
const SICK_ACCURACY_MULT:float = 1
const GOOD_SCORE:int = 100
const GOOD_HEALTH_ADD:float = 0.01
const GOOD_ACCURACY_MULT:float = 0.9
const BAD_SCORE:int = 0
const BAD_HEALTH_ADD:float = 0.005
const BAD_ACCURACY_MULT:float = 0.6
const SHIT_SCORE:int = -150
const SHIT_HEALTH_ADD:float = 0
const SHIT_ACCURACY_MULT:float = 0.3

# public variables
var score:int = 0
var health:float = 1:
	set(value):
		if value > 2:
			health = 2
		elif value < 0:
			value = 0
		health = value

var sicks:int = 0
var goods:int = 0
var bads:int = 0
var shits:int = 0

var misses:int = 0
var combo:int = 0
var combo_breaks:int = 0

var total_hits:float = 0
var total_notes:int:
	get():
		return sicks + goods + bads + shits + misses
var accuracy:float:
	get():
		if total_notes < 1:
			return 100
		elif total_hits < 1:
			return 0
		return (total_hits / total_notes) * 100

func get_clear_rating() -> String:
	if goods == 0 && bads == 0 && shits == 0 && misses == 0:
		return "SFC"
	elif bads == 0 && shits == 0 && misses == 0:
		return "GFC"
	elif misses == 0:
		return "FC"
	elif combo_breaks < 2:
		return "SDCB"
	return "Clear"

func score_note(note:Note) -> String:
	var diff = Conductor.instance.song_position - note.data.time
	combo += 1
	
	var diff_ms:float = absf(diff) * 1000
	if diff_ms <= 45:
		sicks += 1
		score += SICK_SCORE
		health += SICK_HEALTH_ADD
		total_hits += SICK_ACCURACY_MULT
		return "sick"
	elif diff_ms <= 90:
		goods += 1
		score += GOOD_SCORE
		health += GOOD_HEALTH_ADD
		total_hits += GOOD_ACCURACY_MULT
		return "good"
	elif diff_ms <= 135:
		bads += 1
		score += BAD_SCORE
		health += BAD_HEALTH_ADD
		total_hits += BAD_ACCURACY_MULT
		return "bad"
	else:
		shits += 1
		score += SHIT_SCORE
		health += SHIT_HEALTH_ADD
		total_hits += SHIT_ACCURACY_MULT
		return "shit"

func miss_note():
	if combo > 1:
		combo_breaks += 1
		combo = 0
	misses += 1
	health -= 0.04
