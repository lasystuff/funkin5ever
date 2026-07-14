extends Resource
class_name GameStats

# constants
const SICK_SCORE:int = 350
const SICK_HEALTH_ADD:float = 0.02
const GOOD_SCORE:int = 100
const GOOD_HEALTH_ADD:float = 0.01
const BAD_SCORE:int = 0
const BAD_HEALTH_ADD:float = 0.005
const SHIT_SCORE:int = -150
const SHIT_HEALTH_ADD:float = 0

# public variables
var score:int = 0
var health:float = 1:
	set(value):
		if value > 2:
			health = 2
		else:
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
	elif combo_breaks == 0:
		return "SDCB"
	return "Clear"

func score_note(note:Note) -> String:
	var diff = Conductor.instance.song_position - note.data.time
	var judge = judge_wife3(diff)
	if judge > 1.98: # i dont care anymore
		judge = 2
	total_hits += judge
	
	combo += 1
	
	var diff_ms:float = absf(diff) * 1000
	if diff_ms <= 45:
		sicks += 2
		score += SICK_SCORE
		health += SICK_HEALTH_ADD
		return "sick"
	elif diff_ms <= 90:
		goods += 2
		score += GOOD_SCORE
		health += GOOD_HEALTH_ADD
		return "good"
	elif diff_ms <= 135:
		bads += 2
		score += BAD_SCORE
		health += BAD_HEALTH_ADD
		return "bad"
	else:
		shits += 2
		score += SHIT_SCORE
		health += SHIT_HEALTH_ADD
		return "shit"

func miss_note():
	if combo > 1:
		combo_breaks += 1
		combo = 0
	misses += 1
	health -= 0.04

const miss_weight = -5.5
# Wife3 scoring, stole from Troll Engine. You need divide result by two.
func judge_wife3(diff:float):
	var ts:float = 1
	var jPow:float = 0.75
	var max_point:float = 2.0
	var ridic:float = 5 * ts
	var shit_weight:float = 200
	var abs_diff = absf(diff * 1000)
	var zero:float = 65 * pow(ts, jPow)
	var dev:float = 22.7 * pow(ts, jPow)

	if(abs_diff<=ridic):
		return max_point
	elif(abs_diff<=zero):
		return max_point*werwerwerwerf((zero-abs_diff)/dev)
	elif(abs_diff<=shit_weight):
		return (abs_diff-zero)*miss_weight/(shit_weight-zero)
	return miss_weight

const a1 = 0.254829592
const a2 = -0.284496736
const a3 = 1.421413741
const a4 = -1.453152027
const a5 = 1.061405429
const p = 0.3275911

func werwerwerwerf(x:float):
	x = absf(x)
	var t = 1 / (1+p*x)
	var y = 1 - (((((a5*t+a4)*t)+a3)*t+a2)*t+a1)*t*exp(-x*x)
	return absf(y)
