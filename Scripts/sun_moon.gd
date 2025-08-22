extends Node2D

@onready var sun:  CanvasItem = $"."
@onready var moon: CanvasItem = $"../Moon"   # adjust if your Moon path differs

@export var day_start_hour: int = 6
@export var night_start_hour: int = 18

var _is_day_cached: bool = false

func _ready() -> void:
	Clock.time_changed.connect(_on_time_changed)
	_on_time_changed("", Clock.hour, Clock.minute) # initialize

func _on_time_changed(_txt: String, hour: int, minute: int) -> void:
	var hm := float(hour) + float(minute) / 60.0
	var is_day := (hm >= day_start_hour) and (hm < night_start_hour)

	# Only do work if state changed (prevents stacking tweens every minute)
	if is_day == _is_day_cached:
		return
	_is_day_cached = is_day

	var sun_a:  float = 1.0 if is_day else 0.0
	var moon_a: float = 0.0 if is_day else 1.0


	# Optional: actually toggle visibility after fade finishes
	# create_tween().tween_callback(Callable(self, "_apply_visibility").bind(is_day)).set_delay(fade_time)

func _apply_visibility(is_day: bool) -> void:
	sun.visible  = is_day
	moon.visible = not is_day
