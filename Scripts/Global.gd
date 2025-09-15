extends Node

var water_vis := true

var fish_catch := 0

func _ready() -> void:
	if OS.has_feature("pc"):
		DisplayServer.window_set_size(Vector2i(3840, 2160))

func _process(_delta: float) -> void:
	pass


func _input(_event: InputEvent) -> void:
	
	if _event is InputEventJoypadMotion:
		return
	
	if Input.is_action_just_pressed("ui_up") and fish_catch <= 8:
		fish_catch += 1
	if Input.is_action_just_pressed("ui_down") and fish_catch >= 0:
		fish_catch -= 1
