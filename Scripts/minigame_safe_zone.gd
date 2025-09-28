extends ColorRect

@export var min_y: float = 100.0   # lowest Y position
@export var max_y: float = 400.0   # highest Y position

func _process(_delta: float) -> void:
	if Global.minigame_can_jump:
		# pick a random value between min_y and max_y
		var random_y: float = randf_range(min_y, max_y)

		# move the rect to the new Y position
		position.y = random_y

		# optional: only move once per trigger
		Global.minigame_can_jump = false
