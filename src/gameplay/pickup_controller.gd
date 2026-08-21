class_name PickupController
extends Area3D

signal collected(
	pickup_id: StringName,
	pickup_type: StringName,
	amount: int,
	collector: Node,
	player_index: int
)
signal expired(pickup_id: StringName)

@export_category("Pickup")
@export var pickup_id: StringName = &"pickup"
@export var pickup_type: StringName = &"score"
@export_range(1, 100000, 1) var amount: int = 1
@export var pickup_texture: Texture2D
@export var auto_collect_on_body_entered: bool = true

@export_category("Presentation")
@export_range(0.0, 2.0, 0.01) var bob_height: float = 0.12
@export_range(0.0, 10.0, 0.01) var bob_speed: float = 2.4
@export_range(0.0, 360.0, 0.1) var spin_degrees_per_second: float = 45.0
@export_range(0.0, 300.0, 0.1) var lifetime_seconds: float = 15.0

var _elapsed: float = 0.0
var _origin_y: float
var _was_collected: bool = false
var sprite: Sprite3D


func _ready() -> void:
	_origin_y = position.y
	_ensure_sprite()
	if auto_collect_on_body_entered:
		body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	if _was_collected:
		return
	_elapsed += maxf(delta, 0.0)
	position.y = _origin_y + sin(_elapsed * bob_speed) * bob_height
	rotate_y(deg_to_rad(spin_degrees_per_second) * delta)
	if lifetime_seconds > 0.0 and _elapsed >= lifetime_seconds:
		expired.emit(pickup_id)
		queue_free()


func collect(collector: Node, player_index: int = -1) -> bool:
	if _was_collected or collector == null:
		return false
	_was_collected = true
	monitoring = false
	monitorable = false
	if collector.has_method("receive_pickup"):
		collector.call("receive_pickup", pickup_type, amount)
	collected.emit(pickup_id, pickup_type, amount, collector, player_index)
	queue_free()
	return true


func _on_body_entered(body: Node3D) -> void:
	collect(body, int(body.get_meta("player_index", -1)))


func _ensure_sprite() -> void:
	sprite = get_node_or_null("Sprite3D") as Sprite3D
	if sprite == null:
		sprite = Sprite3D.new()
		sprite.name = "Sprite3D"
		add_child(sprite)
	sprite.texture = pickup_texture
	sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
