extends Node

@onready var water_vis := true
@onready var ship_moves := false
@onready var ship_can_move := true
@onready var fish_catch := 0
@onready var fish_game = true
@onready var catch = false
@onready var input_blocked = false

@onready var fish_difficulty = 0
var caught_this_round := false  # new flag

func _ready() -> void:
	if OS.has_feature("pc"):
		DisplayServer.window_set_size(Vector2i(3840, 2160))

func _process(_delta: float) -> void:
	if fish_difficulty >= 5 and not caught_this_round:
		fish_game = false
		fish_catch += 1
		fish_difficulty = 0
		caught_this_round = true
		print("fish catch = ", fish_catch)

	# Reset the flag when ready for next catch
	if fish_difficulty < 5:
		caught_this_round = false
