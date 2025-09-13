extends ColorRect

@export_range(0.0, 360.0, 0.1)
var target_angle_degrees: float = 20.0

@export var forward_speed_deg_per_sec: float = 180.0
@export var return_speed_deg_per_sec: float = 90.0
@export var default_rotation_degrees: float = 0.0
@export var pivot_to_center: bool = true

# --- Plugin Node2D control ---
@export var rope_node_path: NodePath                 # assign your Node2D (plugin) here
@export var rope_length_on_release: float = 200.0

# Prefer one of these if your plugin exposes them:
@export var rope_setter_method: String = ""          # e.g. "set_rope_length"
@export var rope_property_name: String = "Rope Length" # exact property name (spaces OK)

const FALLBACK_PROPS: PackedStringArray = ["rope_length", "length", "rest_length", "max_length"]
const FALLBACK_SETTERS: PackedStringArray = ["set_rope_length", "set_length", "set_rest_length", "set_max_length"]

var _desired_angle: float = 0.0

func _ready() -> void:
	if pivot_to_center:
		pivot_offset = size / 2.0
		resized.connect(func():
			if pivot_to_center:
				pivot_offset = size / 2.0
		)

	rotation_degrees = default_rotation_degrees

func _process(delta: float) -> void:
	var pressed: bool = Input.is_action_pressed("ui_accept")

	_desired_angle = default_rotation_degrees + (target_angle_degrees if pressed else 0.0)
	var speed: float = forward_speed_deg_per_sec if pressed else return_speed_deg_per_sec

	rotation_degrees = move_toward(rotation_degrees, _desired_angle, speed * delta)

	# On release, set the plugin node's rope length
	if Input.is_action_just_released("ui_accept"):
		_apply_rope_length(rope_length_on_release)

func _apply_rope_length(new_length: float) -> void:
	# Only proceed if a node is assigned AND exists
	if rope_node_path == NodePath():
		return
	if not has_node(rope_node_path):
		return

	var rope: Object = get_node(rope_node_path)  # guaranteed non-null
	var clamped: float = max(0.0, new_length)

	# 1) Preferred explicit setter method
	if rope_setter_method != "" and rope.has_method(rope_setter_method):
		rope.call(rope_setter_method, clamped)
		return

	# 2) Explicit property name (works even with spaces)
	if rope_property_name != "" and _has_property(rope, rope_property_name):
		rope.set(rope_property_name, clamped)
		return

	# 3) Fallback properties
	for prop: String in FALLBACK_PROPS:
		if _has_property(rope, prop):
			rope.set(prop, clamped)
			return

	# 4) Fallback setters
	for m: String in FALLBACK_SETTERS:
		if rope.has_method(m):
			rope.call(m, clamped)
			return

	push_warning("Could not set rope length: no matching property or setter found on the target Node2D.")

func _has_property(obj: Object, prop_name: String) -> bool:
	var plist: Array = obj.get_property_list()
	for entry in plist:
		var d: Dictionary = entry
		if d.get("name", "") == prop_name:
			return true
	return false
