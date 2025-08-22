extends Node2D

@export var fade_start: int = 18   # stars start fading in at 18:00 (6PM)
@export var fade_end: int = 6     # stars fade out completely by 06:00
@export var max_alpha: float = 0.8

func _process(_delta: float) -> void:
	var hour = Clock.hour
	var minute = Clock.minute
	var h: float = float(hour) + float(minute) / 60.0

	var alpha: float = 0.0

	if h >= fade_start:
		# evening: fade in between fade_start and 24
		var t = (h - fade_start) / float(24 - fade_start)
		alpha = lerp(0.0, max_alpha, t)
	elif h <= fade_end:
		# early morning: fade out between 0 and fade_end
		var t = 1.0 - (h / float(fade_end))
		alpha = lerp(0.0, max_alpha, t)
	else:
		alpha = 0.0  # daytime = invisible

	modulate.a = clamp(alpha, 0.0, max_alpha)
