extends Button

@export var hull : Button
@export var price = 0

func _process(delta: float) -> void:
	if Global.coins >= price:
		hull.disabled = false
	
