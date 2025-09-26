extends CenterContainer
var fish_to_be_destroyed


func _process(_delta: float) -> void:
	
	if Input.is_action_just_pressed("ui_accept") and Global.fish_game:
		Global.fish_catch += 1
		Global.fish_game = false
		print("fishes = ", Global.fish_catch)
		#this helps me identify the fish that will need to get despawned
		Global.fish_is_in_minigame = false
		Global.fish_to_be_destroyed.queue_free()
