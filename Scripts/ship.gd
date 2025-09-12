extends Node2D

@export var speed: float = 200.0       # Max movement speed (pixels/sec)
@export var acceleration: float = 800  # How fast we speed up
@export var friction: float = 1000     # How fast we slow down
@export var sprite: Node2D             # Drag your Sprite2D or AnimatedSprite2D here

var velocity: float = 0.0  # current horizontal velocity

func _process(delta: float) -> void:
	var input_dir := 0.0
	
	if Input.is_action_pressed("ui_left"):
		input_dir -= 1.0
	if Input.is_action_pressed("ui_right"):
		input_dir += 1.0

	# Apply acceleration or friction
	if input_dir != 0:
		velocity = move_toward(velocity, input_dir * speed, acceleration * delta)
	else:
		velocity = move_toward(velocity, 0, friction * delta)

	# Move the node
	position.x += velocity * delta

	# Flip sprite if moving
	if velocity < -1 and sprite:
		sprite.scale.x = -abs(sprite.scale.x)  # face left
	elif velocity > 1 and sprite:
		sprite.scale.x = abs(sprite.scale.x)   # face right
