extends Label

func _process(delta: float) -> void:
	if Global.shop_entered:
		$".".visible = true
	else:
		$".".visible = false
