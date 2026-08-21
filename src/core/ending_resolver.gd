extends RefCounted
class_name EndingResolver

## Resolves the three arcade endings. The good threshold has priority over
## the original units-digit-zero bad-ending condition.

const Rules := preload("res://src/core/arcade_rule_set.gd")

const GOOD: StringName = &"good"
const BAD: StringName = &"bad"
const NORMAL: StringName = &"normal"


func resolve(score: int) -> StringName:
	return resolve_score(score)


func resolve_combined(player_scores: Array[int]) -> StringName:
	var total: int = 0
	for score: int in player_scores:
		total += score
	return resolve_score(total)


static func resolve_score(score: int) -> StringName:
	var non_negative_score: int = maxi(0, score)
	if non_negative_score >= Rules.GOOD_ENDING_SCORE:
		return GOOD
	if non_negative_score % 10 == 0:
		return BAD
	return NORMAL
