extends Camera2D

@export var target: Node2D
@export var lead_pixels: float = 80.0            # How far the camera looks ahead on X (screen pixels)
@export var sprite_for_facing: Node2D            # Optional: Sprite2D/AnimatedSprite2D to read scale.x from
@export var lead_smooth: float = 14.0            # Higher = snappier easing, lower = smoother
@export var idle_lead_delay: float = 1.0         # Seconds idle before lead returns to 0

var _base_offset: Vector2 = Vector2.ZERO         # Stored base offset
var _last_facing: int = 1                        # 1 = right, -1 = left
var _idle_timer: float = 0.0                     # Time since last left/right input
var _lead_active: bool = false                   # Lead starts inactive until movement input

func _ready() -> void:
	_base_offset = offset

func _process(delta: float) -> void:
	if not target:
		return

	if GlobalCamera.camera_hook:
		target = $"../Ship/Ship/fishing_rod_base/Rope/RopeAnchor/BaitHook"
		$".".offset.y = 0
		
	if GlobalCamera.camera_ship:
		target = $"../Ship"
		$".".offset.y = -820.0
	
		
			# Always keep camera position snapped to the target
	global_position = target.global_position

	# --- Determine facing (for horizontal lead) ---
	var facing: int = _last_facing
	if sprite_for_facing:
		var s := signf(sprite_for_facing.scale.x)
		if s != 0.0:
			facing = 1 if s > 0.0 else -1
	else:
		var ts := signf(target.scale.x)
		if ts != 0.0:
			facing = 1 if ts > 0.0 else -1

	if "velocity" in target:
		var v = target.get("velocity")
		if typeof(v) == TYPE_VECTOR2 and absf(v.x) > 1.0:
			facing = 1 if v.x > 0.0 else -1
		elif typeof(v) == TYPE_FLOAT and absf(v) > 1.0:
			facing = 1 if v > 0.0 else -1
	_last_facing = facing

	# --- Lead activation & idle timer ---
	if Input.is_action_pressed("ui_left") and Global.ship_can_move or Input.is_action_pressed("ui_right") and Global.ship_can_move:
		_idle_timer = 0.0
		_lead_active = true   # activate lead the first time input is pressed
	else:
		_idle_timer += delta

	# --- Desired offset ---
	var desired_offset: Vector2 = _base_offset
	if _lead_active and _idle_timer < idle_lead_delay:
		desired_offset.x += lead_pixels * float(facing)

	# Smooth easing
	if lead_smooth <= 0.0:
		offset = desired_offset
	else:
		var t: float = 1.0 - exp(-lead_smooth * delta)
		offset = offset.lerp(desired_offset, t)
