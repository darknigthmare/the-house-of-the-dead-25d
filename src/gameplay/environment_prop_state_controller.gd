class_name EnvironmentPropStateController
extends RefCounted

const META_PROP_ID := &"environment_prop_id"
const META_INSTANCE := &"environment_prop_instance"
const META_EVENT := &"environment_prop_state_event"
const META_APPLIED := &"environment_prop_state_applied"
const META_TRIGGERED_ID := &"environment_prop_state_triggered_id"


static func configure_sprite(
	sprite: Sprite3D,
	prop_id: String,
	instance_index: int,
	placement: Dictionary
) -> void:
	var frame_count := maxi(1, sprite.hframes * sprite.vframes)
	var initial_frame := clampi(int(placement.get("initial_frame", 0)), 0, frame_count - 1)
	var event := (placement.get("state_event", {}) as Dictionary).duplicate(true)
	sprite.frame = initial_frame
	sprite.set_meta(META_PROP_ID, prop_id)
	sprite.set_meta(META_INSTANCE, instance_index)
	sprite.set_meta(META_EVENT, event)
	sprite.set_meta(META_APPLIED, event.is_empty())
	sprite.set_meta(META_TRIGGERED_ID, "")


static func apply_pending_event(sprite: Sprite3D, context: Dictionary) -> bool:
	if bool(sprite.get_meta(META_APPLIED, true)):
		return false
	var event := sprite.get_meta(META_EVENT, {}) as Dictionary
	if event.is_empty() or not event_is_triggered(event, context):
		return false
	var frame_count := maxi(1, sprite.hframes * sprite.vframes)
	sprite.frame = clampi(int(event.get("target_frame", 0)), 0, frame_count - 1)
	sprite.set_meta(META_APPLIED, true)
	sprite.set_meta(META_TRIGGERED_ID, str(event.get("id", event.get("trigger", ""))))
	return true


static func event_is_triggered(event: Dictionary, context: Dictionary) -> bool:
	match str(event.get("trigger", "")):
		"node_enter":
			return true
		"elapsed":
			return float(context.get("node_elapsed", 0.0)) >= float(event.get("at", 0.0))
		"encounter_clear":
			return bool(context.get("encounter_clear", false))
		"node_complete_success":
			return bool(context.get("node_completing", false)) and bool(context.get("branch_success", false))
		"breakable_destroyed":
			return (
				not bool(context.get("node_completing", false))
				and bool(context.get("breakable_destroyed", false))
				and str(context.get("breakable_id", "")) == str(event.get("breakable_id", ""))
			)
		"boss_phase":
			return int(context.get("boss_phase", 0)) >= int(event.get("phase", 0))
	return false


# A snapshot is data-only: never retain references to scene nodes after cleanup.
static func capture_state(sprite: Sprite3D) -> Dictionary:
	if sprite == null or not is_instance_valid(sprite):
		return {}
	return {
		"frame": sprite.frame,
		"applied": bool(sprite.get_meta(META_APPLIED, true)),
		"triggered_id": str(sprite.get_meta(META_TRIGGERED_ID, "")),
	}


static func restore_state(sprite: Sprite3D, snapshot: Dictionary) -> bool:
	if sprite == null or not is_instance_valid(sprite) or snapshot.is_empty():
		return false
	var frame_count := maxi(1, sprite.hframes * sprite.vframes)
	sprite.frame = clampi(int(snapshot.get("frame", sprite.frame)), 0, frame_count - 1)
	sprite.set_meta(META_APPLIED, bool(snapshot.get("applied", true)))
	sprite.set_meta(META_TRIGGERED_ID, str(snapshot.get("triggered_id", "")))
	return true
