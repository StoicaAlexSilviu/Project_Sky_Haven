extends CenterContainer




func _on_area_2d_area_entered(_area: Area2D) -> void:
	Global.catch = true
	print("catch")

func _on_area_2d_area_exited(_area: Area2D) -> void:
	Global.catch = false
	print("losee")

func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("ui_accept") and Global.fish_game:
		Global.fish_catch += 1
		print("fishes = ", Global.fish_catch)
