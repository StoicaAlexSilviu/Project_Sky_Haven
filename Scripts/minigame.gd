extends CenterContainer

@export var game_01: PackedScene
@export var game_02: PackedScene
@export var game_03: PackedScene
@export var spawn_position: Vector2 = Vector2.ZERO  # Set in Inspector

@onready var game_difficulty_number = 0
@onready var rng = RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	_spawn_random_game()  # only once

func _spawn_random_game() -> void:
	var choices: Array[PackedScene] = []
	#if game_01: choices.append(game_01)
	if game_02: choices.append(game_02)
	#if game_03: choices.append(game_03)

	if choices.is_empty():
		push_error("Assign at least one game_* scene in the Inspector.")
		return

	var scene: PackedScene = choices[rng.randi() % choices.size()]
	var instance = scene.instantiate()
	add_child(instance)

	# Position the new scene at a fixed location
	if instance is Node2D or instance is Control:
		instance.position = spawn_position

func _on_area_2d_area_entered(_area: Area2D) -> void:
	Global.catch = true
	print("catch")

func _on_area_2d_area_exited(_area: Area2D) -> void:
	Global.catch = false
	print("losee")

func _input(_event: InputEvent) -> void:
	
	if _event is InputEventJoypadButton:
		return
		
	if Input.is_action_just_pressed("ui_accept") and Global.catch:
		Global.fish_difficulty += 1
		print("Number = ", Global.fish_difficulty)
