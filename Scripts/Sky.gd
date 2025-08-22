extends Node2D

@export var day_length_minutes: float = 1.0
@export var start_hour: int = 7       # <- set your desired start time here
@export var start_minute: int = 0
@export var deg_offset: float = -90.0 # rotate so noon is “up”; tweak if needed


var time_of_day: float = 0.0 # 0.0 = 00:00, 0.5 = 12:00, 1.0 = 24:00

func _ready() -> void:
	_set_start_time(start_hour, start_minute)
	_apply_rotation()
	# publish immediately so the UI shows 07:00 without a 00:00 flash
	Clock.set_time(get_hour(), get_minute())

func _process(delta: float) -> void:
	var day_seconds := day_length_minutes * 60.0
	time_of_day = wrapf(time_of_day + delta / day_seconds, 0.0, 1.0)
	_apply_rotation()
	Clock.set_time(get_hour(), get_minute())

func _set_start_time(h: int, m: int) -> void:
	h = clamp(h, 0, 23)
	m = clamp(m, 0, 59)
	time_of_day = (float(h) * 60.0 + float(m)) / (24.0 * 60.0)

func _apply_rotation() -> void:
	rotation_degrees = (time_of_day * 360.0) + deg_offset

func get_hour() -> int:
	return wrapi(int(time_of_day * 24.0), 0, 24)

func get_minute() -> int:
	var total_minutes: int = int(time_of_day * 24.0 * 60.0)
	return total_minutes % 60
