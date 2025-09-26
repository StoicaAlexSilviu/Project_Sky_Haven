extends Area2D
@onready var fish_entering_collision

func _ready() -> void:
	monitoring = true
	body_entered.connect(_on_entered)
	
func _on_entered(body: Node) -> void:
	if body.is_in_group(&"fish"):
		if randf() < body.chance_to_catch:
			# Broadcast to anything in the "game" group. No connections needed.
			get_tree().call_group(&"game", "on_trigger", self, body)
			if Global.fish_is_in_minigame == false:
				Global.fish_to_be_destroyed = body
				Global.fish_is_in_minigame = true
