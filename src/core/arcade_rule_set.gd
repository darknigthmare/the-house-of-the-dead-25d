extends RefCounted
class_name ArcadeRuleSet

## Canonical deterministic rules shared by the arcade-domain controllers.

const PLAYER_COUNT: int = 2
const MAGAZINE_SIZE: int = 6
const STARTING_LIVES: int = 3
const MAX_LIVES: int = 5
const STARTING_CREDITS: int = 3
const GOOD_ENDING_SCORE: int = 62_000

const SCORE_CIVILIAN_SAVED: int = 400
const SCORE_CIVILIAN_KILLED_BY_MONSTER: int = -100
const SCORE_CIVILIAN_KILLED_BY_PLAYER: int = -200
const SCORE_ENEMY_KILLED: int = 80
const SCORE_HEADSHOT: int = 120
const SCORE_PLAYER_HIT: int = -100
const SCORE_MEDAL: int = 200
const SCORE_GOLDEN_FROG: int = 1_000
const SCORE_BOSS_DEFEATED: int = 1_500
const SCORE_MAGICIAN_DEFEATED: int = 2_500

const EVENT_CIVILIAN_SAVED: StringName = &"civilian_saved"
const EVENT_CIVILIAN_KILLED_BY_MONSTER: StringName = &"civilian_killed_by_monster"
const EVENT_CIVILIAN_KILLED_BY_PLAYER: StringName = &"civilian_killed_by_player"
const EVENT_ENEMY_KILLED: StringName = &"enemy_killed"
const EVENT_HEADSHOT: StringName = &"headshot"
const EVENT_PLAYER_HIT: StringName = &"player_hit"
const EVENT_MEDAL: StringName = &"medal"
const EVENT_GOLDEN_FROG: StringName = &"golden_frog"
const EVENT_BOSS_DEFEATED: StringName = &"boss_defeated"
const EVENT_MAGICIAN_DEFEATED: StringName = &"magician_defeated"

const SCORE_VALUES: Dictionary = {
	EVENT_CIVILIAN_SAVED: SCORE_CIVILIAN_SAVED,
	EVENT_CIVILIAN_KILLED_BY_MONSTER: SCORE_CIVILIAN_KILLED_BY_MONSTER,
	EVENT_CIVILIAN_KILLED_BY_PLAYER: SCORE_CIVILIAN_KILLED_BY_PLAYER,
	EVENT_ENEMY_KILLED: SCORE_ENEMY_KILLED,
	EVENT_HEADSHOT: SCORE_HEADSHOT,
	EVENT_PLAYER_HIT: SCORE_PLAYER_HIT,
	EVENT_MEDAL: SCORE_MEDAL,
	EVENT_GOLDEN_FROG: SCORE_GOLDEN_FROG,
	EVENT_BOSS_DEFEATED: SCORE_BOSS_DEFEATED,
	EVENT_MAGICIAN_DEFEATED: SCORE_MAGICIAN_DEFEATED,
}


static func score_for(event_name: StringName) -> int:
	return int(SCORE_VALUES.get(event_name, 0))


static func is_valid_player(player_index: int) -> bool:
	return player_index >= 0 and player_index < PLAYER_COUNT
