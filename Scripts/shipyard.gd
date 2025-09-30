extends Label

func _process(_delta: float) -> void:
	if Global.shipyard_entered:
		$".".visible = true
	else:
		$".".visible = false
