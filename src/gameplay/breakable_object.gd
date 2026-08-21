class_name BreakableObject
extends StaticBody3D

signal damaged(amount: float, remaining_durability: float, source_peer_id: int)
signal broken(source_peer_id: int)
signal drop_requested(drop_definition: Dictionary, world_position: Vector3)

@export_category("Breakable")
@export var object_id: StringName = &"breakable"
@export_range(0.01, 10000.0, 0.01) var max_durability: float = 1.0
@export var intact_texture: Texture2D
@export var broken_texture: Texture2D
@export var remove_after_break: bool = false
@export_range(0.0, 30.0, 0.1) var removal_delay: float = 0.6

@export_category("Drops")
@export var drop_table: Array[Dictionary] = []

var durability: float
var is_broken: bool = false
var sprite: Sprite3D
var _random := RandomNumberGenerator.new()


func _ready() -> void:
	durability = max_durability
	_random.randomize()
	_ensure_sprite()


func take_damage(amount: float, _hit_zone: StringName = &"body", source_peer_id: int = 0) -> bool:
	if is_broken or amount <= 0.0:
		return false
	durability = maxf(0.0, durability - amount)
	damaged.emit(amount, durability, source_peer_id)
	if durability <= 0.0:
		break_object(source_peer_id)
	return true


func break_object(source_peer_id: int = 0) -> void:
	if is_broken:
		return
	is_broken = true
	collision_layer = 0
	collision_mask = 0
	if sprite != null:
		if broken_texture != null:
			sprite.texture = broken_texture
		else:
			sprite.visible = false
	broken.emit(source_peer_id)
	var drop := choose_drop()
	if not drop.is_empty():
		drop_requested.emit(drop, global_position)
	if remove_after_break:
		get_tree().create_timer(removal_delay).timeout.connect(queue_free)


func choose_drop() -> Dictionary:
	var total_weight := 0.0
	for entry in drop_table:
		total_weight += maxf(0.0, float(entry.get("weight", 1.0)))
	if total_weight <= 0.0:
		return {}
	var roll := _random.randf_range(0.0, total_weight)
	for entry in drop_table:
		roll -= maxf(0.0, float(entry.get("weight", 1.0)))
		if roll <= 0.0:
			return entry.duplicate(true)
	return drop_table.back().duplicate(true) if not drop_table.is_empty() else {}


func repair(amount: float) -> float:
	if amount <= 0.0:
		return durability
	is_broken = false
	durability = minf(max_durability, durability + amount)
	collision_layer = 1
	if sprite != null:
		sprite.visible = true
		sprite.texture = intact_texture
	return durability


func _ensure_sprite() -> void:
	sprite = get_node_or_null("Sprite3D") as Sprite3D
	if sprite == null:
		sprite = Sprite3D.new()
		sprite.name = "Sprite3D"
		add_child(sprite)
	sprite.texture = intact_texture
	sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
