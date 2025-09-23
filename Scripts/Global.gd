extends Node

@onready var water_vis := true
@onready var ship_moves := false
@onready var ship_can_move := true
@onready var fish_catch := 0
@onready var fish_game = false
@onready var input_blocked = false
@onready var coins = 0

var caught_this_round := false  # new flag

func _ready() -> void:
	if OS.has_feature("pc"):
		DisplayServer.window_set_size(Vector2i(3840, 2160))

func _process(_delta: float) -> void:
	if fish_catch == 8:
		fish_game = false
