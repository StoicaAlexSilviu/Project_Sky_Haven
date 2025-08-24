extends Node2D

# --- Assign your child nodes ---
@onready var sun:  CanvasItem = $Sun
@onready var moon: CanvasItem = $Moon

# --- Time / rotation (phase) ---
@export var day_length_minutes: float = 1.0
@export var start_hour: int = 7
@export var start_minute: int = 0
@export var deg_offset: float = -90.0    # phase along the orbit in degrees (where 00:00 sits); was "noon up" before

var time_of_day: float = 0.0 # 0..1 (0=00:00, 0.5=12:00, 1=24:00)

# --- Elliptical orbit controls ---
@export var radius_x: float = 400.0      # horizontal radius (bigger = wider)
@export var radius_y: float = 200.0      # vertical radius (smaller = squashed)
@export var tilt_deg: float = 20.0       # rotate the ellipse itself (tilt)

# --- Keep sprites from spinning (optional) ---
@export var lock_orientation: bool = true
@export var sun_lock_angle_deg: float = 0.0
@export var moon_lock_angle_deg: float = 0.0

# --- Fade windows (hours) ---
@export var sunrise_start: float = 6.0
@export var sunrise_end:   float = 8.0
@export var sunset_start:  float = 18.0
@export var sunset_end:    float = 20.0

@export var sun_max_alpha:  float = 1.0
@export var moon_max_alpha: float = 1.0

func _ready() -> void:
	_set_start_time(start_hour, start_minute)
	_apply_rotation()
	_update_fade()

func _process(delta: float) -> void:
	# advance time
	var day_seconds: float = day_length_minutes * 60.0
	time_of_day = wrapf(time_of_day + delta / day_seconds, 0.0, 1.0)
	Clock.set_time(get_hour(), get_minute())

	# orbit + visuals
	_apply_rotation()
	_update_fade()

func _set_start_time(h: int, m: int) -> void:
	h = clamp(h, 0, 23)
	m = clamp(m, 0, 59)
	time_of_day = (float(h) * 60.0 + float(m)) / (24.0 * 60.0)

func _apply_rotation() -> void:
	# Elliptical orbit driven by time_of_day
	# angle goes 0..360 over the day, then we add phase (deg_offset)
	var angle_deg: float = (time_of_day * 360.0) + deg_offset
	var angle_rad: float = deg_to_rad(angle_deg)

	# base ellipse position
	var x: float = cos(angle_rad) * radius_x
	var y: float = sin(angle_rad) * radius_y
	var pos: Vector2 = Vector2(x, y)

	# tilt the ellipse
	var tilt_rad: float = deg_to_rad(tilt_deg)
	pos = pos.rotated(tilt_rad)

	# place bodies (center is this node's origin)
	sun.position  = pos
	moon.position = -pos  # opposite side

	# keep sprites' orientation steady if desired
	if lock_orientation:
		sun.rotation_degrees  = sun_lock_angle_deg
		moon.rotation_degrees = moon_lock_angle_deg

func _update_fade() -> void:
	var h: float = time_of_day * 24.0
	var s: float = _sun_strength(h) # 0..1

	# Explicitly typed; cast clamp() to float to avoid Variant inference
	var sa: float = float(clamp(s * sun_max_alpha, 0.0, 1.0))
	var ma: float = float(clamp((1.0 - s) * moon_max_alpha, 0.0, 1.0))

	sun.modulate.a = sa
	moon.modulate.a = ma

	if sun is Light2D:
		(sun as Light2D).energy = 2.0 * sa
	if moon is Light2D:
		(moon as Light2D).energy = 1.5 * ma

func _sun_strength(h: float) -> float:
	# 0 at night → ramp up sunrise → 1 in day → ramp down sunset → 0 at night
	if h < sunrise_start or h >= sunset_end:
		return 0.0
	elif h < sunrise_end:
		return _smooth01((h - sunrise_start) / (sunrise_end - sunrise_start))
	elif h < sunset_start:
		return 1.0
	elif h < sunset_end:
		return 1.0 - _smooth01((h - sunset_start) / (sunset_end - sunset_start))
	return 0.0

func _smooth01(x: float) -> float:
	x = clamp(x, 0.0, 1.0)
	return x * x * (3.0 - 2.0 * x)

func get_hour() -> int:
	return wrapi(int(time_of_day * 24.0), 0, 24)

func get_minute() -> int:
	var total_minutes: int = int(time_of_day * 24.0 * 60.0)
	return total_minutes % 60
