extends Control

@export var time_label: Label 
@export var minigame : CenterContainer
func _ready() -> void:
	Clock.time_changed.connect(_on_time_changed)
	time_label.text = Clock.text # initialize

func _on_time_changed(text: String, _h: int, _m: int) -> void:
	time_label.text = text

func _process(_delta: float) -> void:
	
	if Global.fish_game:
		minigame.visible = true
	else:
		minigame.visible = false
