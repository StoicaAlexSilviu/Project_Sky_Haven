extends Control

@export var time_label: Label
@export var minigame_scene: PackedScene  # assign your Minigame.tscn here
@export var toggle_action: StringName = &"minigame_toggle"

var minigame_instance: Node = null

func _ready() -> void:
	Clock.time_changed.connect(_on_time_changed)
	time_label.text = Clock.text
	set_process(true) # only needed if you disabled it elsewhere

func _on_time_changed(text: String, _h: int, _m: int) -> void:
	time_label.text = text

func _input(event: InputEvent) -> void:
	
	if event is InputEventJoypadMotion:
		return
	$CanvasLayer/Coins.text = str("Coins : ", Global.coins)
	
	if Input.is_action_just_pressed(toggle_action):
		Global.fish_game = true
		

func _process(_delta: float) -> void:
	if Global.fish_game and minigame_instance == null:
		_spawn_minigame()
	
	if !Global.fish_game:
		_unload_minigame()

func _spawn_minigame() -> void:
	if minigame_instance != null:
		return
	minigame_instance = minigame_scene.instantiate()
	$CanvasLayer.add_child(minigame_instance)


func _unload_minigame() -> void:
	if minigame_instance == null:
		return
	minigame_instance.queue_free()
	minigame_instance = null
