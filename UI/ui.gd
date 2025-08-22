extends Control

@export var time_label: Label 

func _ready() -> void:
	Clock.time_changed.connect(_on_time_changed)
	time_label.text = Clock.text # initialize

func _on_time_changed(text: String, _h: int, _m: int) -> void:
	time_label.text = text
