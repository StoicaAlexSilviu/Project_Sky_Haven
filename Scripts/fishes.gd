extends Node2D
@export var count: int = 12
# Size of the rectangular spawn area (centered on this node)
@export var spawn_size: Vector2 = Vector2(1400, 800)
@onready var notifier: VisibleOnScreenNotifier2D = $Notifier
@onready var spawn_area_rect: ColorRect = $SpawnerArea
@export var fish_types: Array[PackedScene] = [] 
@export var weights: Array[float] = []   
var _has_spawned := false

func _ready() -> void:
	_update_notifier_rect()

func _process(_delta: float) -> void:
	if _has_spawned:
		return
	# ← Poll every frame: true as soon as ANY part of notifier.rect touches the camera view
	if notifier.is_on_screen():
		_has_spawned = true
		_spawn_fish_batch()

func set_spawn_size(v: Vector2) -> void:
	spawn_size = v
	_update_notifier_rect()

func _spawn_fish_batch() -> void:
	assert(fish_types.size() > 0, "Assign Fish.tscn to fish_type.")
	if weights.size() != fish_types.size():
		# default to equal weights if not set
		weights = []
		for i in fish_types.size():
			weights.append(1.0)
	randomize()

	var rect := _global_spawn_rect()  # this is now the fish 'ocean'

	for i in count:
		var scene := _pick_weighted(fish_types, weights)
		var f := scene.instantiate()
		add_child(f)
		# place inside local rect then convert to global
		f.global_position = to_global(_random_point_in_local_rect())
		# tell the fish to stay inside the spawner rect
		f.ocean_rect = rect

func _pick_weighted(arr: Array[PackedScene], w: Array[float]) -> PackedScene:
	var total := 0.0
	for x in w: total += max(0.0, x)
	var r := randf() * total
	var run := 0.0
	for i in arr.size():
		run += max(0.0, w[i])
		if r <= run:
			return arr[i]
	return arr.back()

func _random_point_in_local_rect() -> Vector2:
	var half := spawn_size * 0.5
	return Vector2(randf_range(-half.x, half.x), randf_range(-half.y, half.y))

func _global_spawn_rect() -> Rect2:
	# axis-aligned rect centered on this node (assumes no rotation on the spawner)
	var half := spawn_size * 0.5
	return Rect2(global_position - half, spawn_size)

func _update_notifier_rect() -> void:
	var half := spawn_size * 0.5
	notifier.rect = Rect2(-half, spawn_size)


func _draw() -> void:
	# Editor gizmo (also shows at runtime; remove if you want runtime hidden)
	var half := spawn_size * 0.5
	var r := Rect2(-half, spawn_size)
	draw_rect(r, Color(0.2, 0.7, 1.0, 0.08), true)
	draw_rect(r, Color(0.2, 0.7, 1.0, 0.9), false, 2.0)
