extends Node2D

# --- Assign your child nodes ---
@onready var sun:  CanvasItem = $Sun
@onready var moon: CanvasItem = $Moon

# --- Time / rotation ---
@export var day_length_minutes: float = 1.0
@export var start_hour: int = 7
@export var start_minute: int = 0
@export var deg_offset: float = -90.0    # rotate so noon is "up" if desired

var time_of_day: float = 0.0 # 0..1 (0=00:00, 0.5=12:00, 1=24:00)

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
	var day_seconds := day_length_minutes * 60.0
	time_of_day = wrapf(time_of_day + delta / day_seconds, 0.0, 1.0)

	# rotate + visuals
	_apply_rotation()
	_update_fade()

func _set_start_time(h: int, m: int) -> void:
	h = clamp(h, 0, 23)
	m = clamp(m, 0, 59)
	time_of_day = (float(h) * 60.0 + float(m)) / (24.0 * 60.0)

func _apply_rotation() -> void:
	rotation_degrees = (time_of_day * 360.0) + deg_offset
	if lock_orientation:
		var parent_global_deg := rad_to_deg(global_rotation)
		if is_instance_valid(sun):  sun.rotation_degrees  = sun_lock_angle_deg  - parent_global_deg
		if is_instance_valid(moon): moon.rotation_degrees = moon_lock_angle_deg - parent_global_deg

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
