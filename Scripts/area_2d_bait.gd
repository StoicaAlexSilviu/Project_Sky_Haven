extends Area2D

func _ready() -> void:
	monitoring = true
	body_entered.connect(_on_entered)

func _on_entered(body: Node) -> void:
	if body.is_in_group(&"fish"):
		# Broadcast to anything in the "game" group. No connections needed.
		get_tree().call_group(&"game", "on_trigger", self, body)
	print("something")
