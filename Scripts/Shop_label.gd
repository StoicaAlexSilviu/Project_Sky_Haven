extends Label

func _process(_delta: float) -> void:
	if Global.shop_entered:
		$".".visible = true
	else:
		$".".visible = false
