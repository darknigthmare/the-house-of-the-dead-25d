extends RefCounted

# Timing is expressed in 60 Hz physics ticks. Every attack hits once.
const LIGHT := {"start": 5, "end": 17, "reach": 125, "damage": 7, "stun": 10}
const HEAVY := {"start": 12, "end": 34, "reach": 165, "damage": 14, "stun": 15}
const THROW := {"start": 7, "end": 39, "reach": 94, "damage": 16, "stun": 20}
const SPECIALS := [
	{"start": 12, "end": 38, "reach": 700, "damage": 10, "stun": 13},
	{"start": 8, "end": 32, "reach": 530, "damage": 8, "stun": 12},
	{"start": 22, "end": 53, "reach": 245, "damage": 23, "stun": 20},
	{"start": 20, "end": 48, "reach": 760, "damage": 15, "stun": 18}
]
const NAMES := ["Thomas Rogan", "Agent G", "Chariot", "Magician"]
const IDS := ["thomas_rogan", "agent_g", "chariot", "magician"]
const SPEED := [5.1, 5.8, 3.9, 5.4]
const SPECIAL_NAMES := ["Tir AMS", "Tir réflexe", "Fauchage", "Orbe thermique"]
const FINISHERS := ["Sceau AMS", "Extinction des feux", "Sentence de fer", "Combustion"]
const STORY := [[1, 2, 3], [0, 3, 2], [1, 0, 3], [2, 1, 0]]
const STORY_STAGES := [[0, 1, 2], [0, 2, 1], [0, 1, 2], [1, 2, 0]]

var id: int
var x: float
var altitude := 0.0
var vy := 0.0
var facing := 1
var health := 100
var ammo := 6
var stun := 0
var action := ""
var tick := 0
var connected := false
var confirmed := false
var guarding := false
var crouching := false
var moving := false
var combo := 0
var combo_window := 0
var buffered := ""
var buffer_ticks := 0

func _init(identity: int, position_x: float, direction: int) -> void:
	id = identity
	x = position_x
	facing = direction

func move_data() -> Dictionary:
	match action:
		"light": return LIGHT
		"heavy": return HEAVY
		"throw": return THROW
		"special": return SPECIALS[id]
	return {}

func begin(command: String) -> bool:
	if command == "" or stun > 0:
		return false
	if command == "jump":
		if action == "" and altitude <= 0.0:
			vy = 13.2
			return true
		return false
	if action != "":
		# A confirmed light can chain to a heavy, a confirmed heavy to a special.
		if not confirmed or not ((action == "light" and command == "heavy") or (action == "heavy" and command == "special")):
			return false
	if command == "reload" and (id >= 2 or ammo == 6 or altitude > 0.0):
		return false
	if command == "special" and id < 2:
		if ammo == 0: return false
		ammo -= 1
	action = command
	tick = 0
	connected = false
	confirmed = false
	guarding = false
	return true

func step(axis: int, down: bool, command: String, other_x: float) -> void:
	if action == "":
		facing = 1 if other_x >= x else -1
	if stun > 0:
		stun -= 1
	combo_window = maxi(0, combo_window - 1)
	if combo_window == 0:
		combo = 0
	if command != "":
		buffered = command
		buffer_ticks = 5
	if buffer_ticks > 0:
		if begin(buffered):
			buffer_ticks = 0
		else:
			buffer_ticks -= 1
	if altitude > 0.0 or vy > 0.0:
		altitude = maxf(0.0, altitude + vy)
		vy -= 0.72
		if altitude == 0.0: vy = 0.0
	crouching = down and altitude == 0.0 and action == "" and stun == 0
	guarding = axis == -facing and altitude == 0.0 and action == "" and stun == 0
	moving = axis != 0 and not crouching and action == "" and stun == 0
	if moving:
		x += axis * float(SPEED[id]) * (0.58 if guarding else 1.0)
	if action == "": return
	tick += 1
	if action == "reload":
		if tick >= 40:
			ammo = 6
			action = ""
	elif tick >= int(move_data().end):
		action = ""

func can_strike(target) -> bool:
	if action == "" or action == "reload" or connected: return false
	var move := move_data()
	if tick < int(move.start) or tick > int(move.start) + 2: return false
	var separation: float = (target.x - x) * facing
	if separation < -16 or separation > float(move.reach): return false
	if action == "special" and id < 2 and target.crouching: return false
	if action == "throw" and (altitude > 0.0 or target.altitude > 0.0): return false
	return absf(altitude - target.altitude) < 89.0

func hit(target) -> bool:
	var move := move_data()
	var blocked: bool = target.guarding and action != "throw"
	connected = true
	if blocked:
		target.x += facing * 6
		return false
	confirmed = true
	target.health = maxi(0, target.health - int(move.damage))
	target.stun = int(move.stun)
	target.x += facing * (17 if action != "throw" else 42)
	combo += 1
	combo_window = 32
	return true
