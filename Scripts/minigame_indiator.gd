@tool
extends Sprite2D

@export_node_path("Line2D") var circle_path_node: NodePath
@export var start_angle_deg: float = 0.0 : set = set_start_angle
@export var angular_speed_deg: float = 90.0
@export var clockwise: bool = true
@export var paused: bool = false
@export var facing_offset_deg: float = 0.0

var _angle_rad: float = 0.0

func _ready() -> void:
	_angle_rad = deg_to_rad(start_angle_deg)
	_snap_to_circle()
	_face_center()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		_snap_to_circle()
		_face_center()
		return
	if paused:
		return
	var dir: float = -1.0 if clockwise else 1.0
	_angle_rad = wrapf(_angle_rad + dir * deg_to_rad(angular_speed_deg) * delta, -TAU, TAU)
	_snap_to_circle()
	_face_center()

func set_start_angle(v: float) -> void:
	start_angle_deg = v
	_angle_rad = deg_to_rad(v)
	_snap_to_circle()
	_face_center()

# ---- helpers (unchanged) ----
func _read_circle() -> Dictionary:
	var result: Dictionary = {}
	var line: Node = (get_node(circle_path_node) as Node) if circle_path_node != NodePath("") else null
	if line == null:
		result["ok"] = false
		return result
	var cv = line.get("center_local")
	var dv = line.get("diameter")
	var ok_center: bool = typeof(cv) == TYPE_VECTOR2
	var ok_diam: bool = (typeof(dv) == TYPE_FLOAT) or (typeof(dv) == TYPE_INT)
	if !ok_center or !ok_diam:
		result["ok"] = false
		return result
	var center: Vector2 = cv
	var radius: float = max(float(dv) * 0.5, 0.0)
	result["ok"] = true
	result["center"] = center
	result["radius"] = radius
	return result

func _snap_to_circle() -> void:
	var params: Dictionary = _read_circle()
	if !params.get("ok", false):
		return
	var center_parent: Vector2 = params["center"]
	var radius: float = params["radius"]
	position = center_parent + Vector2(cos(_angle_rad), sin(_angle_rad)) * radius

func _face_center() -> void:
	var params: Dictionary = _read_circle()
	if !params.get("ok", false):
		return
	var center_parent: Vector2 = params["center"]
	var dir_to_center: Vector2 = center_parent - position
	if dir_to_center.length() > 0.0001:
		rotation = dir_to_center.angle() + deg_to_rad(facing_offset_deg)
