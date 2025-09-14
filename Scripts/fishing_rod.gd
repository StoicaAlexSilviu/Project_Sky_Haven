extends ColorRect

# --- Rope target node ---
@export var rope_node_path: NodePath                       # assign your Node2D (plugin) here

# Preferred ways your plugin might expose rope length:
@export var rope_setter_method: String = ""                # e.g. "set_rope_length"
@export var rope_property_name: String = "Rope Length"     # exact property name (spaces OK)

const FALLBACK_PROPS: PackedStringArray   = ["rope_length", "length", "rest_length", "max_length"]
const FALLBACK_SETTERS: PackedStringArray = ["set_rope_length", "set_length", "set_rest_length", "set_max_length"]

# --- Input & limits ---
@export var increase_action: StringName = &"ui_up"         # change to your desired action name
@export var decrease_action: StringName = &"ui_down"       # change to your desired action name
@export var rope_change_speed: float = 200.0               # units per second
@export var rope_min_length: float = 0.0
@export var rope_max_length: float = 1000.0
@export var default_rope_length: float = 200.0             # used if we can't read current value

var _rope_len: float = 0.0
var _last_applied_len: float = -INF

func _ready() -> void:
	# Initialize _rope_len from the rope if possible, otherwise use default
	_rope_len = _read_rope_length()
	if is_nan(_rope_len):
		_rope_len = clampf(default_rope_length, rope_min_length, rope_max_length)
	_apply_rope_length(_rope_len) # ensure target starts consistent

func _process(delta: float) -> void:
	var inc := Input.is_action_pressed(increase_action)
	var dec := Input.is_action_pressed(decrease_action)

	if inc and not dec:
		_rope_len += rope_change_speed * delta
		GlobalCamera.camera_hook = true
	elif dec and not inc:
		_rope_len -= rope_change_speed * delta
	# if both or neither are pressed, do nothing

	_rope_len = clampf(_rope_len, rope_min_length, rope_max_length)

	# Avoid spamming the setter if nothing changed meaningfully
	if absf(_rope_len - _last_applied_len) > 0.001:
		_apply_rope_length(_rope_len)
		_last_applied_len = _rope_len

# ----------------- Helpers -----------------

func _apply_rope_length(new_length: float) -> void:
	if rope_node_path == NodePath():
		return
	if not has_node(rope_node_path):
		return

	var rope: Object = get_node(rope_node_path)
	var clamped: float = clampf(max(0.0, new_length), rope_min_length, rope_max_length)

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

func _read_rope_length() -> float:
	if rope_node_path == NodePath() or not has_node(rope_node_path):
		return NAN
	var rope: Object = get_node(rope_node_path)

	# Try explicit property name first
	if rope_property_name != "" and _has_property(rope, rope_property_name):
		return float(rope.get(rope_property_name))

	# Try fallback properties
	for prop: String in FALLBACK_PROPS:
		if _has_property(rope, prop):
			return float(rope.get(prop))

	# As a last resort, try common getter methods
	var getters := ["get_rope_length", "get_length", "get_rest_length", "get_max_length"]
	for g in getters:
		if rope.has_method(g):
			return float(rope.call(g))

	return NAN

func _has_property(obj: Object, prop_name: String) -> bool:
	var plist: Array = obj.get_property_list()
	for entry in plist:
		var d: Dictionary = entry
		if d.get("name", "") == prop_name:
			return true
	return false


func _on_area_2d_area_entered(_area: Area2D) -> void:
	Global.water_vis = false


func _on_area_2d_area_exited(_area: Area2D) -> void:
	Global.water_vis = true
