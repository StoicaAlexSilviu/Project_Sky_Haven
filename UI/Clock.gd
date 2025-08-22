extends Node

signal time_changed(text: String, hour: int, minute: int)

var hour: int = 0
var minute: int = 0
var text: String = "00:00"

func set_time(h: int, m: int) -> void:
	h = wrapi(h, 0, 24)
	m = wrapi(m, 0, 60)
	if h == hour and m == minute:
		return # no spam
	hour = h
	minute = m
	text = "%02d:%02d" % [h, m]
	time_changed.emit(text, hour, minute)
