extends CenterContainer


func _process(_delta: float) -> void:
	
	if Input.is_action_just_pressed("ui_accept") and Global.fish_game:
		Global.fish_catch += 1
		Global.fish_game = false
		print("fishes = ", Global.fish_catch)
