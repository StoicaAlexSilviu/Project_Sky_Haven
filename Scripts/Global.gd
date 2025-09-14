extends Node

@onready var water_vis = true

# Autoload (Singleton) script in 4.2.1
func _ready() -> void:
	if OS.has_feature("pc"):
		DisplayServer.window_set_size(Vector2i(3840, 2160))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
