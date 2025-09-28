extends Sprite2D

@export var speed: float = 100.0        # movement speed (pixels per second)
@export var distance: float = 50.0      # max distance from start position

var start_pos: Vector2
var direction: int = -1                 # -1 = up, 1 = down

func _ready() -> void:
	start_pos = position

func _process(delta: float) -> void:
	# Move sprite up or down
	position.y += direction * speed * delta

	# Check bounds
	if position.y <= start_pos.y - distance:
		position.y = start_pos.y - distance
		direction = 1
	elif position.y >= start_pos.y + distance:
		position.y = start_pos.y + distance
		direction = -1
