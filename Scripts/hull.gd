extends Button

@export var hull : Button
@export var price = 0

func _process(_delta: float) -> void:
	if Global.coins >= price:
		hull.disabled = false
