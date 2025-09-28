extends Label

func _process(_delta: float) -> void:
	
	$".".text = str("Mistakes: ", Global.minigame_mistakes)
