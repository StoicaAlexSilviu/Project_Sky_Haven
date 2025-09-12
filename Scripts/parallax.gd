extends Sprite2D

# Horizontal drift
@export var amplitude_x_range: Vector2 = Vector2(10, 30)   # min, max
@export var speed_x_range: Vector2 = Vector2(0.5, 2.0)

# Vertical drift
@export var amplitude_y_range: Vector2 = Vector2(5, 15)    # min, max
@export var speed_y_range: Vector2 = Vector2(0.5, 2.0)

var time := 0.0
var start_position: Vector2

# Randomized values per sprite
var amplitude_x: float
var amplitude_y: float
var speed_x: float
var speed_y: float
var phase_offset_x: float
var phase_offset_y: float

func _ready() -> void:
	start_position = position
	randomize()

	# Pick random values in the ranges
	amplitude_x = randf_range(amplitude_x_range.x, amplitude_x_range.y)
	amplitude_y = randf_range(amplitude_y_range.x, amplitude_y_range.y)
	speed_x = randf_range(speed_x_range.x, speed_x_range.y)
	speed_y = randf_range(speed_y_range.x, speed_y_range.y)

	# Random starting offsets (0 to 2π)
	phase_offset_x = randf() * TAU
	phase_offset_y = randf() * TAU

func _process(delta: float) -> void:
	time += delta
	var offset_x = sin(time * speed_x + phase_offset_x) * amplitude_x
	var offset_y = cos(time * speed_y + phase_offset_y) * amplitude_y
	position = start_position + Vector2(offset_x, offset_y)
