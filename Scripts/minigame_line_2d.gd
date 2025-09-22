# Godot 4.4.1
@tool
extends Line2D

@export var diameter: float = 200.0 : set = set_diameter
@export var center_local: Vector2 = Vector2.ZERO : set = set_center
@export var segments: int = 128 : set = set_segments
@export var show_in_game: bool = false
@export var rebuild_now: bool = false : set = set_rebuild_now  # click to force-refresh

func _enter_tree() -> void:
	# Make it obvious in editor
	width = max(width, 2.0)
	default_color = Color(0.2, 0.6, 1.0, 1.0)
	closed = true
	z_as_relative = false
	z_index = 4096
	modulate.a = 1.0
	_rebuild()

func _ready() -> void:
	visible = show_in_game or Engine.is_editor_hint()

func _process(_dt: float) -> void:
	# Keep editor-only unless you opt in
	visible = show_in_game or Engine.is_editor_hint()

func set_diameter(v: float) -> void:
	diameter = max(v, 0.0)
	_rebuild()

func set_center(v: Vector2) -> void:
	center_local = v
	_rebuild()

func set_segments(v: int) -> void:
	segments = max(v, 8)
	_rebuild()

func set_rebuild_now(_v: bool) -> void:
	rebuild_now = false
	_rebuild()

func _rebuild() -> void:
	var r: float = max(diameter * 0.5, 0.0)
	var segs: int = max(segments, 8)

	# Build points in this node's local space (which equals the parent's space if Position = (0,0))
	clear_points()
	for i in segs:
		var t: float = float(i) / float(segs) * TAU
		add_point(center_local + Vector2(cos(t), sin(t)) * r)
