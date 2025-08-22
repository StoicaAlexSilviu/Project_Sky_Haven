extends CanvasModulate

@export var day_night_gradient: GradientTexture1D

func _ready() -> void:
	Clock.time_changed.connect(_on_time_changed)
	_on_time_changed(Clock.text, Clock.hour, Clock.minute)

func _on_time_changed(_txt: String, hour: int, minute: int) -> void:
	if day_night_gradient == null:
		return
	var t: float = (hour + minute / 60.0) / 24.0
	var c: Color = day_night_gradient.gradient.sample(t)
	color = c                   # apply locally
	SkyTint.set_tint(c)         # broadcast globally
