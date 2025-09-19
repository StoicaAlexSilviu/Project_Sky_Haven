extends CenterContainer

@onready var game_01 = $Sprite2D/Game1
@onready var game_02 = $Sprite2D/Game2
@onready var game_03 = $Sprite2D/Game3

@onready var rng = RandomNumberGenerator.new()
var game_random_number: int = 0

func _ready() -> void:
	rng.randomize()
	_play_random_game()

func _process(_delta: float) -> void:

	if game_random_number == 1:
		game_01.visible = true
	else:
		game_01.visible = false
	
	if game_random_number == 2:
		game_02.visible = true
	else:
		game_02.visible = false
	
	if game_random_number == 3:
		game_03.visible = true
	else:
		game_03.visible = false


func _play_random_game() -> void:
	game_random_number = rng.randi_range(1,3)
