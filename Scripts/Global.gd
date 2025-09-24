extends Node

@onready var water_vis := true
@onready var ship_moves := false
@onready var ship_can_move := true
@onready var fish_catch := 0
@onready var fish_game = false
@onready var input_blocked = false
@onready var coins = 0

var load_global_script
var caught_this_round := false  # new flag

func _ready() -> void:
	if OS.has_feature("pc"):
		DisplayServer.window_set_size(Vector2i(3840, 2160))
#Below is used to trigger the game when fish enter colision
	add_to_group(&"game")

func _process(_delta: float) -> void:
	if fish_catch == 8:
		fish_game = false

#Below is used to trigger the game when fish enter colision
func on_trigger(trigger: Area2D, body: CharacterBody2D) -> void:
	fish_game = true
