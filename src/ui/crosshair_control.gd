class_name CrosshairControl
extends Control

@export var player_color: Color = Color("#ef3340"):
	set(value):
		player_color = value
		queue_redraw()
@export_range(8.0, 48.0, 1.0) var radius: float = 18.0:
	set(value):
		radius = value
		custom_minimum_size = Vector2.ONE * (radius * 2.0 + 8.0)
		queue_redraw()

var flash_strength: float = 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2.ONE * (radius * 2.0 + 8.0)
	queue_redraw()


func set_screen_position(screen_position: Vector2) -> void:
	position = screen_position - size * 0.5


func pulse() -> void:
	flash_strength = 1.0
	queue_redraw()


func _process(delta: float) -> void:
	if flash_strength > 0.0:
		flash_strength = maxf(0.0, flash_strength - delta * 5.0)
		queue_redraw()


func _draw() -> void:
	var center := size * 0.5
	var tint := player_color.lerp(Color.WHITE, flash_strength)
	var shadow := Color(0.0, 0.0, 0.0, 0.8)
	for offset in [Vector2(1.0, 1.0), Vector2.ZERO]:
		var color := shadow if offset != Vector2.ZERO else tint
		var width := 4.0 if offset != Vector2.ZERO else 2.0
		draw_arc(center + offset, radius, 0.0, TAU, 48, color, width, true)
		draw_line(center + Vector2(-radius - 8.0, 0.0) + offset, center + Vector2(-6.0, 0.0) + offset, color, width, true)
		draw_line(center + Vector2(radius + 8.0, 0.0) + offset, center + Vector2(6.0, 0.0) + offset, color, width, true)
		draw_line(center + Vector2(0.0, -radius - 8.0) + offset, center + Vector2(0.0, -6.0) + offset, color, width, true)
		draw_line(center + Vector2(0.0, radius + 8.0) + offset, center + Vector2(0.0, 6.0) + offset, color, width, true)
	draw_circle(center, 2.5, tint)
