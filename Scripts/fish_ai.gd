extends CharacterBody2D

@export var max_speed: float = 120.0
@export var max_force: float = 140.0
@export var turn_smooth: float = 6.0

@export var wander_jitter: float = 10
@export var wander_radius: float = 100
@export var wander_distance: float = 200


@export var ocean_rect: Rect2 = Rect2(Vector2.ZERO, Vector2(1920, 1080))

var _wander_target: Vector2
@onready var sprite: Sprite2D = $"Sprite2D - Fish1"
var _wander_theta: float = 0.0  

func _ready() -> void:
	randomize()
	velocity = Vector2.RIGHT.rotated(randf() * TAU) * randf_range(40.0, max_speed * 0.8)
	_wander_theta = randf() * TAU

func _physics_process(delta: float) -> void:
	var steering := _wander(delta) + _bounds_force()
	steering = steering.limit_length(max_force)
	velocity += steering * delta
	velocity = velocity.limit_length(max_speed)

	move_and_slide()

	if velocity.length() > 1.0:
		var target_angle := velocity.angle()
		rotation = lerp_angle(rotation, target_angle, turn_smooth * delta)

func _wander(delta: float) -> Vector2:
	var dtheta: float = randf_range(-1.0, 1.0) * (wander_jitter * delta) / max(1.0, wander_radius)
	_wander_theta += dtheta
	var f: Vector2 = _forward_dir()                                # forward (unit)
	var l: Vector2 = Vector2(-f.y, f.x)                            # left (unit), 90° ccw from forward
	var circle_center: Vector2 = global_position + f * wander_distance
	var offset: Vector2 = (cos(_wander_theta) * l + sin(_wander_theta) * f) * wander_radius
	var target: Vector2 = circle_center + offset
	return _seek(target)

func _bounds_force() -> Vector2:
	var margin := 120.0
	var steer := Vector2.ZERO
	var p0 := ocean_rect.position
	var p1 := ocean_rect.end

	if global_position.x < p0.x + margin: steer += Vector2.RIGHT * max_force
	elif global_position.x > p1.x - margin: steer += Vector2.LEFT * max_force
	if global_position.y < p0.y + margin: steer += Vector2.DOWN * max_force
	elif global_position.y > p1.y - margin: steer += Vector2.UP * max_force
	return steer

func _seek(target: Vector2) -> Vector2:
	var desired := (target - global_position)
	if desired == Vector2.ZERO:
		return Vector2.ZERO
	desired = desired.normalized() * max_speed
	return desired - velocity

func _forward_dir() -> Vector2:
	if velocity.length() > 0.01:
		return velocity.normalized()
	else:
		return Vector2.RIGHT
