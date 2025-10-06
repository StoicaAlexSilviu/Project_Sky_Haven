extends Node

@onready var water_vis := false
@onready var ship_moves := false
@onready var ship_can_move := true
@onready var fish_catch := 0
@onready var fishing_done = false
@onready var fish_game = false
@onready var input_blocked = false
@onready var coins = 100
@onready var fish_value = 1
@onready var shop_entered = false
@onready var shipyard_entered = false
@onready var indicator_in = false
@onready var minigame_mistakes = 0
@onready var minigame_hits = 0
@onready var minigame_can_jump = false

@onready var slots = 0
@onready var hull_01 = true
@onready var hull_02 = false
@onready var hull_03 = false
@onready var hull_04 = false
#this helps me identify the fish that will need to get despawned
@onready var fish_is_in_minigame = false
@onready var fish_to_be_destroyed
#this helps me give a chance for the fish to catch the bait
@onready var chace_to_catch


var load_global_script
var caught_this_round := false  # new flag

func _ready() -> void:
	water_vis = true
	
	if OS.has_feature("pc"):
		DisplayServer.window_set_size(Vector2i(3840, 2160))
#Below is used to trigger the game when fish enter colision
	add_to_group(&"game")

func _process(_delta: float) -> void:
	
	if hull_01:
		slots = 5
	if hull_02:
		slots = 8
	
	if fish_catch == slots:
		fishing_done = true
		fish_game = false
		
	if fish_catch == 0:
		fishing_done = false
		
	if Input.is_action_just_pressed("ui_accept") and shop_entered:
		get_tree().change_scene_to_file("res://Levels/Scenes/shop_scene.tscn")
	
	if Input.is_action_just_pressed("ui_accept") and shipyard_entered:
		get_tree().change_scene_to_file("res://Levels/Scenes/Shipyard.tscn")
#Below is used to trigger the game when fish enter colision
func on_trigger(_trigger: Area2D, _body: CharacterBody2D) -> void:
	fish_game = true
