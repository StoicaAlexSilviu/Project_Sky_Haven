extends Node2D

@export var fish_scene: PackedScene
@export var count: int = 12
@export var spawn_rect: Rect2 = Rect2(-2800, 1900, 3080, 1020)  # where to place fish initially
@export var randomize_params: bool = true                   # give each fish small variations

func _ready() -> void:
	assert(fish_scene != null, "Assign Fish.tscn to fish in the Inspector.")
	randomize()

	# Auto-fit the fish "ocean" to the current viewport
	#var vr := get_viewport_rect()
	#var ocean_rect := Rect2(vr.position, vr.size)

	for i in count:
		var f := fish_scene.instantiate()                    # your Fish.tscn root is CharacterBody2D
		add_child(f)

		# Position inside the spawn area
		var x := randf_range(spawn_rect.position.x, spawn_rect.end.x)
		var y := randf_range(spawn_rect.position.y, spawn_rect.end.y)
		f.global_position = Vector2(x, y)
