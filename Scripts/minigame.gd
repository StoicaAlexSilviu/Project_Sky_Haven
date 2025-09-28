extends CenterContainer
#var fish_to_be_destroyed
@export var mistakes = 0
@export var hits = 0
func _process(_delta: float) -> void:
	
	if Input.is_action_just_pressed("ui_accept") and Global.fish_game and Global.indicator_in:
		Global.minigame_hits += 1
		Global.minigame_can_jump = true
		print(Global.minigame_hits)
	
	if Global.fish_game and Global.minigame_hits == hits:
		Global.fish_catch += 1
		Global.fish_game = false
		Global.minigame_can_jump = false
		#print("fishes = ", Global.fish_catch)
		#this helps me identify the fish that will need to get despawned
		Global.indicator_in = false
		Global.minigame_hits = 0
		Global.fish_is_in_minigame = false
		Global.minigame_mistakes = 0
		Global.fish_to_be_destroyed.queue_free()
	
	if $MinigameBg/Counter.text == str("00:00"):
		#print("fish lost")
		Global.minigame_can_jump = false
		Global.minigame_hits = 0
		Global.fish_game = false
		Global.indicator_in = false
		Global.fish_is_in_minigame = false
		Global.minigame_mistakes = 0
		
	if Global.minigame_mistakes == mistakes:
		#print("mistakes")
		Global.minigame_can_jump = false
		Global.minigame_hits = 0
		Global.fish_game = false
		Global.indicator_in = false
		Global.fish_is_in_minigame = false
		Global.minigame_mistakes = 0
	
	if Input.is_action_just_pressed("ui_accept") and Global.fish_game and !Global.indicator_in:
		Global.minigame_mistakes += 1
