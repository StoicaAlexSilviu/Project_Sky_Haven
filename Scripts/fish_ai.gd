# Fish.gd (Godot 4 / GDScript 4)
extends CharacterBody2D

# --- Movement tuning ---
@export var max_speed: float = 120.0        # cruising speed
@export var turn_smooth: float = 6.0        # how fast the sprite turns to face velocity

# --- Angle-based wander (simple + stable) ---
@export var wander_jitter_deg: float = 50.0   # heading wiggle speed (deg/sec)
@export var max_wander_angle_deg: float = 18.0# clamp wobble ±deg
@export var heading_centering: float = 1.0    # pulls wobble toward 0 (0 = off)
@export var vertical_wobble_gain: float = 2.8   # 1.0 = current; 1.5–2.5 = more up/down


# --- Screen bounds (push back inward near edges) ---
@export var ocean_rect: Rect2 = Rect2(Vector2.ZERO, Vector2(1920, 1080))
@export var margin: float = 120.0            # start steering inward when this close to edges
@export var flip_cooldown: float = 0.35   # seconds to ignore further flips


@onready var sprite: Sprite2D = $"Sprite2D - Fish1"

var _base_forward: Vector2   # initial left/right cruise direction
var _yaw: float = 0.0                        # tiny wobble angle around base_forward (radians)
var _cooldown_left: float = 0.0

func _ready() -> void:
	randomize()
	ocean_rect = Rect2(get_viewport_rect().position*120/100, get_viewport_rect().size*120/100)
	if randf()<0.5:
		_base_forward = Vector2.RIGHT 
	else:
		_base_forward = Vector2.LEFT
		sprite.flip_v == true
	# start facing left or right
	_yaw = 0.0
	velocity = _base_forward * max_speed * 0.7

func _physics_process(delta: float) -> void:
	# --- tiny random walk on heading (keeps motion alive) ---		
	_cooldown_left = max(0.0, _cooldown_left - delta)
	_handle_edges()
	var jitter_rad: float = deg_to_rad(wander_jitter_deg) * delta
	_yaw += randf_range(-jitter_rad, jitter_rad)
	_yaw -= _yaw * heading_centering * delta   # soft pull toward horizontal
	_yaw = clamp(_yaw, -deg_to_rad(max_wander_angle_deg), deg_to_rad(max_wander_angle_deg))


	# desired direction & velocity from the wobbled heading
	var dir: Vector2 = _base_forward.rotated(_yaw)
	dir = Vector2(dir.x, dir.y * vertical_wobble_gain).normalized()
	var desired_vel: Vector2 = dir * max_speed

	# steer toward desired velocity + keep inside screen
	var steering: Vector2 = (desired_vel - velocity)
	velocity += steering * delta
	velocity = velocity.limit_length(max_speed)

	move_and_slide()

	# face swim direction
	if velocity.length() > 1.0:
		var target_angle: float = velocity.angle()
		rotation = lerp_angle(rotation, target_angle, turn_smooth * delta)

func _handle_edges() -> void:
	if _cooldown_left > 0.0:
		return
	var p0: Vector2 = ocean_rect.position
	var p1: Vector2 = ocean_rect.end

	# Left/right walls: flip horizontal direction
	if global_position.x < p0.x + margin:
		_base_forward = Vector2.RIGHT
		_yaw = 0.0
		velocity.x = abs(velocity.x)
		_cooldown_left = flip_cooldown
		if sprite.flip_v == true:
			sprite.flip_v = false
		else:
			sprite.flip_v = true   # face right
		return
	elif global_position.x > p1.x - margin:
		_base_forward = Vector2.LEFT
		_yaw = 0.0
		velocity.x = -abs(velocity.x)
		_cooldown_left = flip_cooldown
		if sprite.flip_v == true:
			sprite.flip_v = false
		else:
			sprite.flip_v = true   # face right # face left
		return
	# Top/bottom: softly push away (don’t flip horizontal)
	if global_position.y < p0.y + margin:
		_yaw = abs(_yaw) * 0.5   # tilt downward a bit
		velocity.y = abs(velocity.y)
		_cooldown_left = flip_cooldown
	elif global_position.y > p1.y - margin:
		_yaw = -abs(_yaw) * 0.5  # tilt upward a bit
		velocity.y = -abs(velocity.y)
		_cooldown_left = flip_cooldown
