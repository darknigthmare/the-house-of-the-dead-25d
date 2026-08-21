class_name SpriteActor3D
extends CharacterBody3D

signal damaged(amount: float, hit_zone: StringName, source_peer_id: int)
signal died(source_peer_id: int)
signal destination_reached

enum AnimationState { IDLE, MOVE, ATTACK_WINDUP, ATTACK_STRIKE, HIT, DEATH }

@export_category("Identity")
@export var actor_id: StringName = &"actor"
@export var faction: StringName = &"hostile"

@export_category("Sprite3D Presentation")
@export var sprite_texture: Texture2D
@export_range(0.0001, 0.1, 0.0001) var pixel_size: float = 0.0075
@export_range(1, 64, 1) var sheet_columns: int = 8
@export_range(1, 64, 1) var sheet_rows: int = 8
@export_range(0.0, 60.0, 0.1) var animation_fps: float = 8.0
@export var billboard_enabled: bool = true
@export var full_billboard: bool = false
@export var directional_resolver: DirectionalSpriteResolver

@export_category("Combat")
@export_range(0.01, 100000.0, 0.01) var max_health: float = 1.0
@export var queue_on_death: bool = true
@export_range(0.01, 2.0, 0.01) var attack_windup_duration: float = 0.17
@export_range(0.01, 2.0, 0.01) var attack_strike_duration: float = 0.17
@export_range(0.01, 2.0, 0.01) var hit_reaction_duration: float = 0.22
@export_range(0.01, 5.0, 0.01) var death_visible_duration: float = 0.65

@export_category("Movement")
@export_range(0.0, 100.0, 0.01) var move_speed: float = 2.0
@export_range(0.0, 100.0, 0.01) var acceleration: float = 12.0
@export_range(0.01, 10.0, 0.01) var arrival_distance: float = 0.15

var health: float
var animation_frame: int = 0
var move_target: Vector3
var has_move_target: bool = false
var last_move_direction: Vector3 = Vector3.FORWARD
var sprite: Sprite3D
var _animation_elapsed: float = 0.0
var animation_state: AnimationState = AnimationState.IDLE
var _state_remaining: float = 0.0
var _death_elapsed: float = 0.0
var _move_frame_index: int = 0
var _death_queue_requested: bool = false


func _ready() -> void:
	health = max_health
	_enter_animation_state(AnimationState.IDLE)
	_ensure_sprite()
	_apply_sprite_frame()


func _physics_process(delta: float) -> void:
	if animation_state != AnimationState.DEATH:
		_update_movement(delta)
	_update_animation(delta)


func configure(data: Dictionary) -> void:
	actor_id = StringName(str(data.get("id", actor_id)))
	faction = StringName(str(data.get("faction", faction)))
	max_health = maxf(0.01, float(data.get("health", max_health)))
	health = max_health
	move_speed = maxf(0.0, float(data.get("speed", move_speed)))
	if data.has("texture"):
		var loaded := load(str(data.texture)) as Texture2D
		if loaded != null:
			sprite_texture = loaded
	if is_node_ready():
		_enter_animation_state(AnimationState.IDLE)
		_ensure_sprite()
		_apply_sprite_frame()


func set_move_target(target: Vector3) -> void:
	if animation_state == AnimationState.DEATH:
		return
	move_target = target
	has_move_target = true


func clear_move_target() -> void:
	has_move_target = false
	velocity = Vector3.ZERO
	if animation_state not in [AnimationState.ATTACK_WINDUP, AnimationState.ATTACK_STRIKE, AnimationState.HIT, AnimationState.DEATH]:
		_enter_animation_state(AnimationState.IDLE)
		_apply_sprite_frame()


func play_attack() -> bool:
	if not is_alive() or animation_state in [AnimationState.ATTACK_WINDUP, AnimationState.ATTACK_STRIKE, AnimationState.HIT, AnimationState.DEATH]:
		return false
	_enter_animation_state(AnimationState.ATTACK_WINDUP, attack_windup_duration)
	_apply_sprite_frame()
	return true


func take_damage(amount: float, hit_zone: StringName = &"body", source_peer_id: int = 0) -> bool:
	if not is_alive() or amount <= 0.0:
		return false
	health = maxf(0.0, health - amount)
	damaged.emit(amount, hit_zone, source_peer_id)
	if health <= 0.0:
		has_move_target = false
		velocity = Vector3.ZERO
		_enter_animation_state(AnimationState.DEATH)
		_apply_sprite_frame()
		died.emit(source_peer_id)
	else:
		_enter_animation_state(AnimationState.HIT, hit_reaction_duration)
		_apply_sprite_frame()
	return true


func heal(amount: float) -> float:
	if amount <= 0.0 or not is_alive():
		return health
	health = minf(max_health, health + amount)
	return health


func is_alive() -> bool:
	return health > 0.0


func health_ratio() -> float:
	return clampf(health / maxf(max_health, 0.01), 0.0, 1.0)


func _update_movement(delta: float) -> void:
	var desired_velocity := Vector3.ZERO
	if has_move_target:
		var offset := move_target - global_position
		offset.y = 0.0
		if offset.length() <= arrival_distance:
			has_move_target = false
			destination_reached.emit()
		else:
			last_move_direction = offset.normalized()
			desired_velocity = last_move_direction * move_speed
	velocity = velocity.move_toward(desired_velocity, acceleration * maxf(delta, 0.0))
	if not velocity.is_zero_approx():
		move_and_slide()


func _update_animation(delta: float) -> void:
	var remaining_delta := maxf(delta, 0.0)
	if animation_state == AnimationState.DEATH:
		animation_frame = 7
		_death_elapsed += remaining_delta
		_apply_sprite_frame()
		if queue_on_death and not _death_queue_requested and _death_elapsed >= death_visible_duration:
			_death_queue_requested = true
			queue_free()
		return

	var transition_guard := 0
	while remaining_delta > 0.0 and animation_state in [AnimationState.ATTACK_WINDUP, AnimationState.ATTACK_STRIKE, AnimationState.HIT] and transition_guard < 3:
		if _state_remaining > remaining_delta:
			_state_remaining -= remaining_delta
			remaining_delta = 0.0
		else:
			remaining_delta -= maxf(_state_remaining, 0.0)
			if animation_state == AnimationState.ATTACK_WINDUP:
				_enter_animation_state(AnimationState.ATTACK_STRIKE, attack_strike_duration)
			else:
				_sync_locomotion_state()
			transition_guard += 1

	if animation_state not in [AnimationState.ATTACK_WINDUP, AnimationState.ATTACK_STRIKE, AnimationState.HIT]:
		_sync_locomotion_state()
	if animation_state == AnimationState.MOVE and animation_fps > 0.0:
		_animation_elapsed += remaining_delta
		var frame_duration := 1.0 / animation_fps
		while _animation_elapsed >= frame_duration:
			_animation_elapsed -= frame_duration
			_move_frame_index = (_move_frame_index + 1) % 3
			animation_frame = 1 + _move_frame_index
	_apply_sprite_frame()


func _sync_locomotion_state() -> void:
	var next_state := AnimationState.MOVE if not velocity.is_zero_approx() else AnimationState.IDLE
	if animation_state != next_state:
		_enter_animation_state(next_state)


func _enter_animation_state(next_state: AnimationState, duration: float = 0.0) -> void:
	if animation_state == AnimationState.DEATH and next_state != AnimationState.DEATH:
		return
	animation_state = next_state
	_state_remaining = maxf(duration, 0.0)
	match animation_state:
		AnimationState.IDLE:
			animation_frame = 0
			_animation_elapsed = 0.0
		AnimationState.MOVE:
			_move_frame_index = 0
			animation_frame = 1
			_animation_elapsed = 0.0
		AnimationState.ATTACK_WINDUP:
			animation_frame = 4
		AnimationState.ATTACK_STRIKE:
			animation_frame = 5
		AnimationState.HIT:
			animation_frame = 6
		AnimationState.DEATH:
			animation_frame = 7
			_death_elapsed = 0.0
			_death_queue_requested = false


func _apply_sprite_frame() -> void:
	if sprite == null:
		return
	if directional_resolver != null:
		var camera := get_viewport().get_camera_3d()
		var camera_position := global_position - last_move_direction
		if camera != null:
			camera_position = camera.global_position
		directional_resolver.apply_to_sprite(
			sprite,
			last_move_direction,
			camera_position,
			global_position,
			animation_frame
		)
	else:
		sprite.frame = wrapi(animation_frame, 0, maxi(1, sprite.hframes * sprite.vframes))


func _ensure_sprite() -> void:
	sprite = get_node_or_null("Sprite3D") as Sprite3D
	if sprite == null:
		sprite = Sprite3D.new()
		sprite.name = "Sprite3D"
		add_child(sprite)
	sprite.texture = sprite_texture
	sprite.pixel_size = pixel_size
	sprite.hframes = maxi(1, sheet_columns)
	sprite.vframes = maxi(1, sheet_rows)
	if billboard_enabled:
		sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED if full_billboard else BaseMaterial3D.BILLBOARD_FIXED_Y
	else:
		sprite.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	if directional_resolver == null:
		directional_resolver = DirectionalSpriteResolver.new()
		directional_resolver.direction_count = 8
		directional_resolver.frames_per_direction = 8
		directional_resolver.direction_order.assign([0, 1, 2, 3, 4, 5, 6, 7])
