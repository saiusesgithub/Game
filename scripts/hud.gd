class_name GameHUD
extends CanvasLayer

var speed_label: Label
var distance_label: Label
var crash_label: Label

func _ready() -> void:
	speed_label = _label(28)
	speed_label.position = Vector2(28, 22)
	add_child(speed_label)
	distance_label = _label(20)
	distance_label.position = Vector2(30, 62)
	add_child(distance_label)
	crash_label = _label(36)
	crash_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	crash_label.size = Vector2(520, 120)
	crash_label.position = Vector2(0, 190)
	crash_label.anchor_left = 0.5
	crash_label.anchor_right = 0.5
	crash_label.offset_left = -260
	crash_label.offset_right = 260
	crash_label.visible = false
	add_child(crash_label)

func _label(font_size: int) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(0.96, 0.96, 0.90))
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	return label

func update_stats(speed_kph: int, distance_meters: float) -> void:
	speed_label.text = "%03d km/h" % speed_kph
	distance_label.text = "%d m" % roundi(distance_meters)

func show_crash() -> void:
	crash_label.text = "CRASHED\nPress R to restart"
	crash_label.visible = true

func hide_crash() -> void:
	crash_label.visible = false
