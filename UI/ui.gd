extends Control

@export var time_label: Label
@export var minigame_scene: PackedScene  # assign your Minigame.tscn here

var minigame_instance: Node = null

func _ready() -> void:
	Clock.time_changed.connect(_on_time_changed)
	time_label.text = Clock.text # initialize

func _on_time_changed(text: String, _h: int, _m: int) -> void:
	time_label.text = text

func _process(_delta: float) -> void:
	if Global.fish_game:
		# If not already loaded, instance and add it
		if minigame_instance == null:
			minigame_instance = minigame_scene.instantiate()
			$CanvasLayer.add_child(minigame_instance)
	else:
		# If loaded, remove it and free
		if minigame_instance != null:
			minigame_instance.queue_free()
			minigame_instance = null
