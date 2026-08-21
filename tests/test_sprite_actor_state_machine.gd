extends RefCounted

const SpriteActorType := preload("res://src/gameplay/sprite_actor_3d.gd")


static func collect_checks() -> Array[Dictionary]:
	var checks: Array[Dictionary] = []
	var actor = SpriteActorType.new()
	actor.max_health = 3.0
	actor.health = 3.0
	actor.queue_on_death = true

	checks.append(_check(actor.animation_state, SpriteActorType.AnimationState.IDLE, "sprite actor starts idle"))
	checks.append(_check(actor.animation_frame, 0, "idle state uses column zero"))

	actor.velocity = Vector3.RIGHT
	actor._update_animation(0.0)
	checks.append(_check(actor.animation_state, SpriteActorType.AnimationState.MOVE, "velocity enters locomotion"))
	checks.append(_check(actor.animation_frame, 1, "locomotion starts at first movement column"))
	actor._update_animation((1.0 / actor.animation_fps) + 0.001)
	checks.append(_check(actor.animation_frame, 2, "locomotion advances within columns one to three"))

	checks.append(_check(actor.play_attack(), true, "attack can begin from locomotion"))
	checks.append(_check(actor.animation_state, SpriteActorType.AnimationState.ATTACK_WINDUP, "attack begins with windup state"))
	checks.append(_check(actor.animation_frame, 4, "windup uses column four"))
	actor._update_animation(actor.attack_windup_duration)
	checks.append(_check(actor.animation_state, SpriteActorType.AnimationState.ATTACK_STRIKE, "windup advances to strike"))
	checks.append(_check(actor.animation_frame, 5, "strike uses column five"))
	actor._update_animation(actor.attack_strike_duration)
	checks.append(_check(actor.animation_state, SpriteActorType.AnimationState.MOVE, "completed attack returns to locomotion"))
	checks.append(_check(actor.animation_frame, 1, "locomotion restarts at a stable contact frame"))

	actor.velocity = Vector3.ZERO
	actor._update_animation(0.0)
	checks.append(_check(actor.animation_state, SpriteActorType.AnimationState.IDLE, "zero velocity returns to idle"))
	checks.append(_check(actor.animation_frame, 0, "idle restores column zero"))

	checks.append(_check(actor.take_damage(1.0), true, "non-lethal hit is accepted"))
	checks.append(_check(actor.animation_state, SpriteActorType.AnimationState.HIT, "damage enters transient hit state"))
	checks.append(_check(actor.animation_frame, 6, "hit reaction uses column six"))
	checks.append(_check(actor.play_attack(), false, "hit reaction cannot be interrupted by attack"))
	actor._update_animation(actor.hit_reaction_duration)
	checks.append(_check(actor.animation_state, SpriteActorType.AnimationState.IDLE, "hit reaction returns to idle"))
	checks.append(_check(actor.animation_frame, 0, "post-hit idle restores column zero"))

	checks.append(_check(actor.take_damage(2.0), true, "lethal hit is accepted"))
	checks.append(_check(actor.animation_state, SpriteActorType.AnimationState.DEATH, "lethal hit locks death state"))
	checks.append(_check(actor.animation_frame, 7, "death uses column seven"))
	checks.append(_check(actor.is_queued_for_deletion(), false, "death remains visible immediately"))
	actor._update_animation(actor.death_visible_duration - 0.01)
	checks.append(_check(actor.is_queued_for_deletion(), false, "death remains visible for its configured duration"))
	actor.queue_on_death = false
	actor._update_animation(actor.death_visible_duration * 2.0)
	checks.append(_check(actor.animation_state, SpriteActorType.AnimationState.DEATH, "death state is terminal"))
	checks.append(_check(actor.animation_frame, 7, "terminal death keeps the death column"))
	checks.append(_check(actor.play_attack(), false, "dead actor cannot restart an attack"))
	actor.free()
	return checks


static func _check(actual: Variant, expected: Variant, label: String) -> Dictionary:
	return {"actual": actual, "expected": expected, "label": label}
