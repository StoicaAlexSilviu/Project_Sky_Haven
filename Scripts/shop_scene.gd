extends Control

func _ready() -> void:
	$sell.grab_focus()

func _on_sell_pressed() -> void:
	if Global.fish_catch >= 1:
		Global.fish_catch -= 1
		Global.coins += 1

func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/Level_01_TEST/Level_01_TEST.tscn")
