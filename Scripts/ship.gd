extends Node2D

@export var speed: float = 200.0
@export var acceleration: float = 800
@export var friction: float = 1000
@export var sprite: Node2D

# --- Movement sound (2D or 1D) ---
@export var move_sound: Node                  # Assign AudioStreamPlayer2D OR AudioStreamPlayer

@export var min_move_speed_for_sound: float = 10.0  # px/s threshold

# Volumes (dB)
@export var target_volume_db: float = 0.0     # volume when moving
@export var silent_volume_db: float = -80.0   # near-silent when idle

# Exponential fade rates (per second)
@export var fade_in_rate: float = 10.0
@export var fade_out_rate: float = 6.0

# Stop when faded below (silent + margin)
@export var stop_margin_db: float = 3.0

var velocity: float = 0.0
var _current_volume_db: float = -80.0

func _ready() -> void:
	# Auto-find a player if not assigned
	if move_sound == null:
		move_sound = get_node_or_null("AudioStreamPlayer2D")
		if move_sound == null:
			move_sound = get_node_or_null("AudioStreamPlayer")
	if move_sound:
		_current_volume_db = silent_volume_db
		_set_player_volume(_current_volume_db)

func _process(delta: float) -> void:
	var input_dir := 0.0
	if Input.is_action_pressed("ui_left"):  input_dir -= 1.0
	if Input.is_action_pressed("ui_right"): input_dir += 1.0

	# Inertia
	if input_dir != 0.0:
		velocity = move_toward(velocity, input_dir * speed, acceleration * delta)
	else:
		velocity = move_toward(velocity, 0.0, friction * delta)

	# Move
	position.x += velocity * delta

	# Flip sprite
	if sprite:
		if velocity < -1.0:
			sprite.scale.x = -abs(sprite.scale.x)
		elif velocity > 1.0:
			sprite.scale.x = abs(sprite.scale.x)

	# --- Sound with exponential fade ---
	if move_sound:
		var is_moving := absf(velocity) >= min_move_speed_for_sound
		var target_db := target_volume_db if is_moving else silent_volume_db
		var rate := fade_in_rate if is_moving else fade_out_rate

		# Exponential step (framerate-independent)
		var step := 1.0 - exp(-rate * delta)
		_current_volume_db += (target_db - _current_volume_db) * step

		# Snap close to target to avoid the asymptotic tail
		if absf(target_db - _current_volume_db) < 0.1:
			_current_volume_db = target_db

		_set_player_volume(_current_volume_db)

		if is_moving:
			# Ensure playing while moving (restarts non-looping clips)
			if not _is_playing():
				_play()
		else:
			# Stop once we’re essentially silent
			if _current_volume_db <= (silent_volume_db + stop_margin_db) and _is_playing():
				_stop()
				_current_volume_db = silent_volume_db
				_set_player_volume(_current_volume_db)

# ---- Helpers (support both AudioStreamPlayer2D and AudioStreamPlayer) ----
func _is_playing() -> bool:
	if move_sound is AudioStreamPlayer2D:
		return (move_sound as AudioStreamPlayer2D).playing
	elif move_sound is AudioStreamPlayer2D:
		return (move_sound as AudioStreamPlayer2D).playing
	return false

func _play() -> void:
	if move_sound is AudioStreamPlayer2D:
		(move_sound as AudioStreamPlayer2D).play()
	elif move_sound is AudioStreamPlayer2D:
		(move_sound as AudioStreamPlayer2D).play()

func _stop() -> void:
	if move_sound is AudioStreamPlayer2D:
		(move_sound as AudioStreamPlayer2D).stop()
	elif move_sound is AudioStreamPlayer2D:
		(move_sound as AudioStreamPlayer2D).stop()

func _set_player_volume(db: float) -> void:
	if move_sound is AudioStreamPlayer2D:
		(move_sound as AudioStreamPlayer2D).volume_db = db
	elif move_sound is AudioStreamPlayer2D:
		(move_sound as AudioStreamPlayer2D).volume_db = db
