extends Node

signal tint_changed(color: Color)

var color: Color = Color.WHITE

func set_tint(c: Color) -> void:
	if c == color:
		return
	color = c
	tint_changed.emit(color)
