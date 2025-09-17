extends Node2D

@export var fish_scene: PackedScene
@export var count: int = 12
# Size of the rectangular spawn area (centered on this node)
@export var spawn_size: Vector2 = Vector2(1400, 800)
@onready var notifier: VisibleOnScreenNotifier2D = $Notifier
@onready var spawn_area_rect: ColorRect = $SpawnerArea
var _has_spawned := false

func _ready() -> void:
	_update_notifier_rect()
	notifier.screen_entered.connect(_on_screen_entered)  # hide when the game runs

func set_spawn_size(v: Vector2) -> void:
	spawn_size = v
	_update_notifier_rect()
	queue_redraw()

func _on_screen_entered() -> void:
	if _has_spawned:
		return
	_has_spawned = true
	_spawn_fish_batch()

func _spawn_fish_batch() -> void:
	assert(fish_scene != null, "Assign Fish.tscn to fish_scene in the Inspector.")
	randomize()

	var rect := _global_spawn_rect()  # this is now the fish 'ocean'

	for i in count:
		var f := fish_scene.instantiate()
		add_child(f)
		# place inside local rect then convert to global
		f.global_position = to_global(_random_point_in_local_rect())
		# tell the fish to stay inside the spawner rect
		f.ocean_rect = rect

func _random_point_in_local_rect() -> Vector2:
	var half := spawn_size * 0.5
	return Vector2(randf_range(-half.x, half.x), randf_range(-half.y, half.y))

func _global_spawn_rect() -> Rect2:
	# axis-aligned rect centered on this node (assumes no rotation on the spawner)
	var half := spawn_size * 0.5
	return Rect2(global_position - half, spawn_size)

func _update_notifier_rect() -> void:
	if not is_instance_valid(notifier):
		return
	var half := spawn_size * 0.5
	notifier.rect = Rect2(-half, spawn_size)
	
func _update_spawn_area_rect() -> void:
	if not is_instance_valid(spawn_area_rect):
		return
	spawn_area_rect.position = -spawn_size * 0.5  # center it on the parent
	spawn_area_rect.size = spawn_size

func _draw() -> void:
	# Editor gizmo (also shows at runtime; remove if you want runtime hidden)
	var half := spawn_size * 0.5
	var r := Rect2(-half, spawn_size)
	draw_rect(r, Color(0.2, 0.7, 1.0, 0.08), true)
	draw_rect(r, Color(0.2, 0.7, 1.0, 0.9), false, 2.0)
