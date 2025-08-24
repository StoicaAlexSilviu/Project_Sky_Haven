# SunTint.gd  (attach to your Sun Sprite2D)
extends Sprite2D

# --- When sunrise/sunset happen (hours in 24h) ---
@export var sunrise_start: float = 6.0
@export var sunrise_end:   float = 8.0
@export var sunset_start:  float = 18.0
@export var sunset_end:    float = 20.0

# --- Colors to blend through ---
@export var night_color:   Color = Color(1.0, 0.9, 0.6, 0.0) # mostly transparent at night
@export var sunrise_color: Color = Color(1.0, 0.65, 0.35, 1.0)
@export var day_color:     Color = Color(1.0, 0.95, 0.8, 1.0)
@export var sunset_color:  Color = Color(1.0, 0.55, 0.30, 1.0)

func _ready() -> void:
	# Subscribe to Clock updates and set initial color
	Clock.time_changed.connect(_on_time_changed)
	_on_time_changed(Clock.text, Clock.hour, Clock.minute)

func _on_time_changed(_txt: String, hour: int, minute: int) -> void:
	var h: float = float(hour) + float(minute) / 60.0
	modulate = _color_for_hour(h)

func _color_for_hour(h: float) -> Color:
	var c: Color
	if h < sunrise_start or h >= sunset_end:
		# Night
		c = night_color
	elif h < sunrise_end:
		# Sunrise: night -> sunrise -> day
		var t: float = _smooth01((h - sunrise_start) / (sunrise_end - sunrise_start))
		# First warm-up from night to sunrise tint, then to day
		var mid: Color = night_color.lerp(sunrise_color, t)
		c = mid.lerp(day_color, t)
	elif h < sunset_start:
		# Day
		c = day_color
	elif h < sunset_end:
		# Sunset: day -> sunset -> night
		var t2: float = _smooth01((h - sunset_start) / (sunset_end - sunset_start))
		var mid2: Color = day_color.lerp(sunset_color, t2)
		c = mid2.lerp(night_color, t2)
	else:
		c = night_color
	return c

func _smooth01(x: float) -> float:
	x = clamp(x, 0.0, 1.0)
	return x * x * (3.0 - 2.0 * x) # smoothstep for softer edges
